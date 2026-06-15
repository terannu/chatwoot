require 'net/http'
require 'json'
require 'base64'

# Sends mail through Brevo's transactional HTTP API instead of SMTP.
# Hosting platforms (e.g. Railway) often block outbound SMTP ports, so we
# deliver over HTTPS (443) which is never blocked.
class BrevoApiDelivery
  ENDPOINT = 'https://api.brevo.com/v3/smtp/email'.freeze

  def initialize(settings = {})
    @settings = settings
  end

  def deliver!(mail)
    api_key = ENV.fetch('BREVO_API_KEY', nil)
    raise 'BREVO_API_KEY is not set' if api_key.blank?

    response = post(api_key, payload(mail))
    return response if response.is_a?(Net::HTTPSuccess)

    raise "Brevo API delivery failed: #{response.code} #{response.body}"
  end

  private

  def payload(mail)
    {
      sender: sender(mail),
      to: recipients(mail.to),
      cc: recipients(mail.cc),
      bcc: recipients(mail.bcc),
      replyTo: reply_to(mail),
      subject: mail.subject,
      htmlContent: html_content(mail),
      textContent: text_content(mail),
      attachment: attachments(mail)
    }.compact
  end

  def sender(mail)
    address = Array(mail.from).first
    name = mail[:from]&.addrs&.first&.display_name
    { email: address, name: name }.compact
  end

  def reply_to(mail)
    address = Array(mail.reply_to).first
    return nil if address.blank?

    { email: address }
  end

  def recipients(addresses)
    list = Array(addresses).map { |email| { email: email } }
    list.presence
  end

  def html_content(mail)
    part = mail.html_part || (if mail.multipart?
                                nil
                              else
                                (mail.content_type.to_s.include?('html') ? mail : nil)
                              end)
    part&.body&.decoded
  end

  def text_content(mail)
    part = mail.text_part || (if mail.multipart?
                                nil
                              else
                                (mail.content_type.to_s.include?('html') ? nil : mail)
                              end)
    part&.body&.decoded
  end

  def attachments(mail)
    list = mail.attachments.map do |attachment|
      { name: attachment.filename, content: Base64.strict_encode64(attachment.body.decoded) }
    end
    list.presence
  end

  def post(api_key, body)
    uri = URI(ENDPOINT)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.open_timeout = 10
    http.read_timeout = 15

    request = Net::HTTP::Post.new(uri)
    request['api-key'] = api_key
    request['Content-Type'] = 'application/json'
    request['Accept'] = 'application/json'
    request.body = body.to_json

    http.request(request)
  end
end
