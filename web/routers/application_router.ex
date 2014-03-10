defmodule ApplicationRouter do
  use Dynamo.Router

  filter Dynamo.Filters.Head
  filter JSON.Dynamo.Filter
  use HTTPoison.Base
  require Lager

  prepare do
    conn = conn.resp_content_type("application/json")
    conn = conn.put_resp_header("Access-Control-Allow-Origin", "*")
    conn = conn.put_resp_header("Access-Control-Allow-Methods", "POST, GET, OPTIONS")
    conn = conn.put_resp_header("Access-Control-Allow-Headers", "Authorization,X-Requested-With")
    conn = conn.fetch([:cookies, :params])
    conn.assign(:title, "CORS Echo")
  end

  post "/post" do
    conn = conn.resp_content_type("text/html")
    conn = conn.assign(:content, conn.params[:content])
    render conn, "post.html"
  end

  get "/" do
    conn = conn.resp_content_type("text/html")
    render conn, "index.html"
  end

  options "/" do
    conn.resp(200, ~S({"response":"Ola Mundo"}))
  end

  get "/favicon.ico" do
    conn = conn.resp_content_type("image/x-icon")
    {_, binary} = File.read("priv/static/favicon.ico")
    conn.resp 200, binary
  end

  get "/remote/headers/:url" do
    url = URI.decode conn.params[:url]
    Lager.debug "Remote URL: " <> url
    [ _, { _, last_modified }, _, _, _, { _, content_length } ] = (HTTPoison.head url).headers
    { content_length, _ } = Integer.parse(content_length)
    # convert RFC1123 to Unix Time (Sun, 23 Feb 2014 19:33:43 GMT)
    { _, erl_date } = String.to_char_list(last_modified)
    timestamp = :httpd_util.convert_request_date(erl_date)
    unix_time = :calendar.datetime_to_gregorian_seconds(timestamp)-719528*24*3600
    conn.put_private :result_object, [ last_modified: unix_time, length: content_length ]
  end
end
