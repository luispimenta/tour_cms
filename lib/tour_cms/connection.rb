module TourCMS
  class Connection
    def initialize(marketp_id, private_key, result_type = "raw")
      Integer(marketp_id) rescue raise ArgumentError, "Marketplace ID must be an Integer"
      @marketp_id = marketp_id
      @private_key = private_key
      @result_type = result_type
      @base_url = "https://api.tourcms.com"
      @body = ''
    end

    def api_rate_limit_status(channel = 0)
      request("/api/rate_limit_status.xml", channel)
    end

    def list_channels
      request("/p/channels/list.xml")
    end

    def show_channel(channel)
      request("/c/channel/show.xml", channel)
    end

    def search_tours(params = {}, channel = 0)
      if channel == 0
        request("/p/tours/search.xml", 0, params)
      else
        request("/c/tours/search.xml", channel, params)
      end
    end

    def search_hotels_range(params = {}, tour = "", channel = 0)
      if channel == 0
        request("/p/hotels/search_range.xml", 0, params.merge({"single_tour_id" => tour}))
      else
        request("/c/hotels/search_range.xml", channel, params.merge({"single_tour_id" => tour}))
      end
    end

    def search_hotels_specific(params = {}, tour = "", channel = 0)
      if channel == 0
        request("/p/hotels/search-avail.xml", 0, params.merge({"single_tour_id" => tour}))
      else
        request("/c/hotels/search-avail.xml", channel, params.merge({"single_tour_id" => tour}))
      end
    end

    def list_tours(channel = 0)
      if channel == 0
        request("/p/tours/list.xml")
      else
        request("/c/tours/list.xml", channel)
      end
    end

    def list_tour_images(channel = 0)
      if channel == 0
        request("/p/tours/images/list.xml")
      else
        request("/c/tours/images/list.xml", channel)
      end
    end

    def show_tour(tour, channel)
      request("/c/tour/show.xml", channel, {"id" => tour})
    end

    def show_tour_departures(params, channel)
      request("/c/tour/datesprices/dep/show.xml", channel, params)
    end

    def show_tour_freesale(tour, channel)
      request("/c/tour/datesprices/freesale/show.xml", channel, {"id" => tour})
    end

    def check_tour_availability(params, channel)
      request("/c/tour/datesprices/checkavail.xml", channel, params)
    end

    def booking_start_new(body = '', channel)
      @body = body
      request("/c/booking/new/start.xml", channel, {}, "POST")
    end

    def booking_commit_new(body = '', channel)
      @body = body
      request("/c/booking/new/commit.xml", channel, {}, "POST")
    end

    def booking_show(params, channel)
      request("/c/booking/show.xml", channel, params)
    end

    def booking_cancel(body = '', channel)
      @body = body
      request("/c/booking/cancel.xml", channel, {}, "POST")
    end

    def booking_send_email(body = '', channel)
      @body = body
      request("/c/booking/email/send.xml", channel, {}, "POST")
    end

    private

    def generate_signature(path, verb, channel, outbound_time)
      string_to_sign = "#{channel}/#{@marketp_id}/#{verb}/#{outbound_time}#{path}".strip

      dig = OpenSSL::HMAC.digest('sha256', @private_key, string_to_sign)
      b64 = Base64.encode64(dig).chomp
      CGI.escape(b64).gsub("+", "%20")
    end

    def request(path, channel = 0, params = {}, verb = "GET")
      url = URI(@base_url + path + "?#{params.to_query}")

      req_time = Time.now.utc
      signature = generate_signature(path + "?#{params.to_query}", verb, channel, req_time.to_i)

      https = Net::HTTP.new(url.host, url.port)
      https.use_ssl = true

      if verb == 'GET'
        request = Net::HTTP::Get.new(url)
      else
        request = Net::HTTP::Post.new(url)
      end

      request["Content-type"] = "text/xml"
      request["charset"] = "utf-8"
      request["Date"] = req_time.strftime("%a, %d %b %Y %H:%M:%S GMT")
      request["Authorization"] = "TourCMS #{channel}:#{@marketp_id}:#{signature}"

      if @body != ''
        request.body = @body
      end

      response = https.request(request)

      @result_type == "raw" ? response : Hash.from_xml(response.read_body)["response"]
    end
  end
end
