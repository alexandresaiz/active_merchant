module Monei
  # This class represents are request fired to the gateway
  # You can construct instances of this class in a fairly open-ended fashion
  #
  # A request looks like the following
  module Transaction
    class Response
      def initialize(response_xml)
        @response_xml = response_xml
        @doc = nil
      end

      def parse
        @doc = Nokogiri::XML(@response_xml)
      end

      def parsed?
        if @doc.nil?
          return false
        end
        true
      end

      # Returns transaction details in a Hash
      # Given
      # <Transaction mode="LIVE" response="SYNC" channel="678a456b789c123d456e789f012g432">
      # It will return:
      # {:mode=>"LIVE", :response=>"SYNC", :channel=>"678a456b789c123d456e789f012g432"}
      def transaction_data
        parse unless parsed?
        transaction_details_node = @doc.xpath('//Transaction')[0]

        transaction_details_hash = Hash.new
        transaction_details_hash[:mode] = transaction_details_node[:mode]
        transaction_details_hash[:response] = transaction_details_node[:response]
        transaction_details_hash[:channel] = transaction_details_node[:channel]
        transaction_details_hash
      end

      # Returns all identification data as a Hash
      # Given:
      # <Identification>
      # <TransactionID>MerchantAssignedID</TransactionID>
      # <UniqueID>h987i654j321k098l765m432n210o987</UniqueID>
      # <ShortID>1234.5678.9876</ShortID>
      # </Identification>
      # It will return
      # {:transaction_id => MerchantAssignedID, :unique_id => some_unique_id , :short_id => some_short_id
      def identification_data
        parse unless parsed?
        identification_data_node = @doc.xpath('//Transaction/Identification')[0]
        transaction_id_node = @doc.xpath('//Transaction/Identification/TransactionID')[0]
        unique_id_node = @doc.xpath('//Transaction/Identification/UniqueID')[0]
        short_id_node = @doc.xpath('//Transaction/Identification/ShortID')[0]

        identification_data_hash = Hash.new
        identification_data_hash[:transaction_id] = transaction_id_node.text
        identification_data_hash[:short_id] = short_id_node.text
        identification_data_hash[:unique_id] = unique_id_node.text
        identification_data_hash
      end

      # It will return
      # Given:
      # <Processing code="90.00">
      #       <Timestamp>2003-02-12 14:58:07</Timestamp>
      # <Result>ACK</Result>
      #       <Status code="90">NEW</Status>
      # <Reason code="00">Successful Processing</Reason>
      #       <Return code=„000.000.000“>Transaction succeeded</Return>
      # <SecurityHash>2d0ec783cb7c2d5b117499e6211caef4</SecurityHash>
      #       </Processing>
      # <Payment>
      # It will return:
      # {:processing_code=>"90.00", :processing_timestamp=>"2003-02-12 14:58:07", :result=>"ACK", :status_code=>"90", :status_text=>"NEW", :reason_code=>"00", :reason_text=>"Successful Processing", :return_code=>"000.000.000", :return_text=>"Transaction succeeded", :security_hash_code=>"2d0ec783cb7c2d5b117499e6211caef4"}
      def processing_data
        parse unless parsed?

        processing_node = @doc.xpath('//Transaction/Processing')[0]
        processing_timestamp_node = @doc.xpath('//Transaction/Processing/Timestamp')[0]
        result_node = @doc.xpath('//Transaction/Processing/Result')[0]
        status_node = @doc.xpath('//Transaction/Processing/Status')[0]
        reason_node = @doc.xpath('//Transaction/Processing/Reason')[0]
        return_node = @doc.xpath('//Transaction/Processing/Return')[0]
        security_hash_node = @doc.xpath('//Transaction/Processing/SecurityHash')[0]

        processing_data_hash = Hash.new
        processing_data_hash[:processing_code] = processing_node[:code]
        processing_data_hash[:processing_timestamp] = processing_timestamp_node.text
        processing_data_hash[:result] = result_node.text
        processing_data_hash[:status_code] = status_node[:code]
        processing_data_hash[:status_text] = status_node.text
        processing_data_hash[:reason_code] = reason_node[:code]
        processing_data_hash[:reason_text] = reason_node.text
        processing_data_hash[:return_code] = return_node[:code]
        processing_data_hash[:return_text] = return_node.text
        processing_data_hash[:security_hash_code] = security_hash_node.text
        processing_data_hash
      end

      # Returns payment details from resposne
      # Given:
      # <Payment code="DD.DB">
      #     <Clearing>
      #     <Amount>1.00</Amount>
      # <Currency>EUR</Currency>
      #     <Descriptor>shop.de 1234.1234.1234 +49 (89) 12345 678 Order Number
      #     1234</Descriptor>
      # <Date>2003-02-13</Date>
      #     <Support>+49 (89) 1234 567</Support>
      # </Clearing>
      #     </Payment>
      def payment_data
        parse unless parsed?
        payment_node = @doc.xpath('//Transaction/Payment')[0]
        amount_node = @doc.xpath('//Transaction/Payment/Clearing/Amount')[0]
        currency_node = @doc.xpath('//Transaction/Payment/Clearing/Currency')[0]
        descriptor_node = @doc.xpath('//Transaction/Payment/Clearing/Descriptor')[0]
        date_node = @doc.xpath('//Transaction/Payment/Clearing/Date')[0]
        support_node =  @doc.xpath('//Transaction/Payment/Clearing/Support')[0]

        payment_data_hash = Hash.new
        payment_data_hash[:code] = payment_node[:code]
        payment_data_hash[:amount] = amount_node.text
        payment_data_hash[:currency] = currency_node.text
        payment_data_hash[:descriptor] = descriptor_node.text
        payment_data_hash[:date] = date_node.text
        payment_data_hash[:support] = support_node.text
        payment_data_hash
      end
    end
  end
end