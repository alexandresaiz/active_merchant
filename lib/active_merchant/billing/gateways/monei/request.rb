# -*- coding: iso-8859-1 -*-
require 'nokogiri'
require 'net/http'
module Monei
  # This class represents are request fired to the gateway
  # You can construct instances of this class in a fairly open-ended fashion
  #
  # A request looks like the following
  module Transaction
    class Request

      def initialize options_hash
        @options_hash = options_hash
      end

      def build_xml
        builder = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
          xml.Request(:version => "1.0"){
            xml.Header{
              xml.Security(:sender => @options_hash[:security_sender])
            }
            xml.Transaction(:mode => @options_hash[:transaction_mode],
                            :response => @options_hash[:transaction_response],
                            :channel => @options_hash[:transaction_channel]
                            ){
              # Being transaction block ----

              # User block
              xml.User(:login => @options_hash[:user_login],
                       :pwd => @options_hash[:user_password])

              #Identification block
              xml.Identification{
                xml.TransactionID @options_hash[:transaction_id]
              }

              #Payment block
              xml.Payment(:code => @options_hash[:payment_code]){
                xml.Presentation{
                  xml.Amount @options_hash[:amount]
                  xml.Currency @options_hash[:currrency]
                  xml.Usage @options_hash[:order_number]
                }
              }

              #Account block
              xml.Account{
                xml.Holder @options_hash[:account_holder_full_name]
                xml.Number @options_hash[:account_number]
                xml.Bank @options_hash[:bank]
                xml.Country @options_hash[:country]
              }

              #Customer block
              xml.Customer {
                xml.Name{
                  xml.Given @options_hash[:account_holder_given_name]
                  xml.Family @options_hash[:account_holder_family_name]
                }
                xml.Address{
                  xml.Street @options_hash[:street_address]
                  xml.Zip @options_hash[:zipcode]
                  xml.City @options_hash[:city]
                  xml.State @options_hash[:state]
                  xml.Country @options_hash[:country]
                }
                xml.Contact{
                  xml.Email @options_hash[:email]
                  xml.Ip @options_hash[:ip_address]
                }
                #End Customer block
              }
              # End transaction block ----
            }
          }
        end
        builder.to_xml
      end

      def self.fire_request(request_xml, url )
        require 'uri'
        require 'net/http'
        require 'net/https'

        uri  = URI.parse(url)
        https = Net::HTTP.new(uri.host,uri.port)
        https.use_ssl = true
        request_payload = Net::HTTP::Post.new(uri.path, initheader = {'Content-Type' =>'application/x-www-form-urlencoded;charset=UTF-8'})
        request_payload.body = request_xml
        response = https.request(request_payload)
        puts "Response #{response.code} Response Message: #{response.message}: Response Body #{response.body}"
      end

    end
  end
end
