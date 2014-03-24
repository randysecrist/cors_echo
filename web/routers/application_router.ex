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

    { status_code, headers } = try do
      response = HTTPoison.head url
      headers = response.headers
      status_code = response.status_code
      { status_code, headers }
    rescue
      [HTTPoison.HTTPError] -> { nil, [] }
    end

    {content_length, unix_time, etag} = case status_code do
      200 ->
        { content_length, _ } = Integer.parse(headers["Content-Length"])

        unix_time = case headers["Last-Modified"] do
          nil -> nil
          _ -> rfc1123_to_unix(headers["Last-Modified"])
        end

        etag = case headers["ETag"] do
          nil -> nil
          _ -> String.strip(headers["ETag"], ?")
        end
        {content_length, unix_time, etag}
      _ -> {nil, nil, nil}
    end

    conn.put_private :result_object, [
      status_code: status_code,
      last_modified: unix_time,
      content_length: content_length,
      etag: etag,
      title: headers["x-amz-meta-title"],
      description: headers["x-amz-meta-description"] ]
  end

  # convert RFC1123 to Unix Time (Sun, 23 Feb 2014 19:33:43 GMT)
  def rfc1123_to_unix(rfc1123_time) do
    { _, erl_date } = String.to_char_list(rfc1123_time)
    timestamp = :httpd_util.convert_request_date(erl_date)
    :calendar.datetime_to_gregorian_seconds(timestamp)-719528*24*3600
  end
end
