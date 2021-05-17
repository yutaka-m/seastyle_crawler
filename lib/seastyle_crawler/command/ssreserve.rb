require "seastyle_crawler/manager"
require "Date"

module SeastyleCrawler
    class Ssreserve
        def initialize(date_strategy, boat_type, marina_cd, target_boats, site, reserve_status, debug)
            @date_strategy = date_strategy || "weekend"
            @boat_type = boat_type || 1
            @marina_cd = marina_cd || ""
            @target_boats = target_boats || ["SR-X"]
            @site = site || ""
            @reserve_status = reserve_status || 2
            @debug = debug
            if @debug
                p @date_strategy
                p @boat_type
                p @marina_cd
                p @target_boats
                p @site
                p @reserve_status
                p @debug
            end
        end

        def run
            manager = SeastyleCrawler::Manager.new(@site, @debug)
            # generate dates
            datelist = generateDate()
            # get boat number
            boat_type = @boat_type
            # get marina code
            marina_cd = @marina_cd

            datelist.each { |date|
                manager.get(date, boat_type, marina_cd)
            }

            # print difference reservations.
            manager.print_form(@target_boats, @reserve_status)
        end

        def generateDate()
            d = Date.today
            fin = Date.today + 30
            sat_delta_days = (6 - d.wday)
            sun_delta_days = (7 - d.wday)
            weekends = []
            while d < (fin - 7) do
                weekends.push((d + sat_delta_days).strftime("%Y/%m/%d"))
                weekends.push((d + sun_delta_days).strftime("%Y/%m/%d"))
                d = d + 7
            end
            weekends
        end
    end
end
