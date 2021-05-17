require "json"
require "uri"
require "net/http"

module SeastyleCrawler
    class Manager
        def initialize(site, debug)
            @marinas = []
            @reservelist = []
            @boats = []
            @debug = debug || false
            @site = site || ""
        end

        def filter_boat(boats)
            @filter_boat = boats
        end

        def get(date, boat_type, marina_cd)
            # call post
            data = {}
            output = ""
            if @debug
                output = File.read("data")
                #File.open("data.json", "w+") do |f|
                #    f.write(output)
                #end
            else
                res = Net::HTTP.post_form(URI.parse(@site),
                    {"marina_cd"=>marina_cd, "boat_type"=>boat_type, "rsv_date"=>date})
                begin
                    res.value
                rescue => e
                    print e.message
                    exit
                end
                # load moderation....
                sleep(rand*10)
                output = res.body
            end
            output = URI.decode_www_form_component(output).sub(/success:/, '')
            data = JSON.load(output)
            
            unless @marinas.any? { |v| v["marina_cd"] == data["marina_info"]["marina_cd"] }
                @marinas.push(data["marina_info"])
            end

            data["list"].each do |b|
                unless @boats.any? { |v| v["boat_cd"] == b["boat_cd"] }
                    @boats.push(b)
                end
            end

            data["rsv_list"].each do |r|
                unless @reservelist.any? { |v| v["seq_no"] == r["seq_no"] }
                    @reservelist.push(r)
                end
            end
        end

        def print_form(filter, reserve_status)
            if false
                print "marinas"
                p @marinas
                print "boats"
                p @boats
                print "reservelist"
                p @reservelist
            end
            
            target_boats = []
            @boats.each do |b|
                if filter.any? { |v| v == b["boat_model_name"] }
                    target_boats.push(b["boat_cd"])
                end
            end

            matched_reservelist = []
            @reservelist.each do |r|
                if target_boats.include?(r["boat_cd"])
                    matched_reservelist.push(r)
                end
            end

            # print
            output = ""
            matched_reservelist.each do |m|
                tb = @boats.select { |b| b['boat_cd'] == m['boat_cd'] }.first
                if m['rsv_sts'].to_i == reserve_status
                    output += sprintf("#{m['rsv_sts']} #{m['marina_cd']} #{m['rsv_date']} #{tb['boat_model_name']} #{m['avail_time_from']} - #{m['avail_time_to']} #{tb['half_fee']} #{tb['currency_name']} / #{tb['full_fee']} #{tb['currency_name']}\n")
                    p output
                end
            end
            output
        end
    end
end
