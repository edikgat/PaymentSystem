module XMLHelper
  def xml_hash
    @xml ||= begin
      doc = Nokogiri::XML(response.body)
      Hash.from_xml(doc.to_s)['hash']
    end
  end
end

RSpec.configure do |config|
  config.include XMLHelper, type: :request
end
