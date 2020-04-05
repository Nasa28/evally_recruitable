# frozen_string_literal: true

module RecruitDocuments
  class JustjoinitMailParserService
    delegate :mail, :source, :recruit_document, to: :@context

    def initialize(context)
      @context = context
    end

    def perform
      return unless recruit_document.received_status?

      first_name, last_name = fullname.split(' ')

      recruit_document.assign_attributes(
        first_name: first_name&.strip,
        last_name: last_name&.strip,
        email: email,
        phone: nil,
        position: position,
        group: 'Unknown',
        source: 'JustJoinIT',
        received_at: mail.date,
        accept_current_processing: true,
        accept_future_processing: accept_future_processing
      )

      return unless recruit_document.save

      Rails.logger.info("\e[44mJustJoinIT Parser  |  Done!  |  #{mail.message_id}\e[0m")

      save_mail_body
      mail.attachments.each(&method(:save_attachment))
    end

    private

    def plain_text
      @plain_text ||= mail.find_first_mime_type('text/plain')
    end

    def fullname
      mail.subject.to_s.scan(/^(.+)\s+is\s+applying\s+for/i).flatten.first&.strip
    end

    def email
      plain_text.body.to_s.scan(/\*Candidate\s+email\*:\s+(.+@.+)\b/i).flatten.first&.strip
    end

    def position
      mail.subject.to_s.scan(/is\s+applying\s+for\s+(.+)$/i).flatten.first&.strip
    end

    def accept_future_processing
      value = plain_text.body.to_s.scan(/\*.+Processing data in future recruitment\*/).flatten.first

      value.present?
    end

    def save_attachment(attachment)
      Tempfile.open(attachment.filename, '/tmp', encoding: 'ascii-8bit') do |file|
        file << attachment.decoded
        file.rewind

        recruit_document.files.attach(io: file, filename: attachment.filename)
      end
    rescue => e
      Rails.logger.error "\e[31mFile cannot be attached due to error: #{e.message}\e[0m"
    end

    def save_mail_body
      filename = 'message.txt'

      Tempfile.open(filename, '/tmp', encoding: 'ascii-8bit') do |file|
        file << plain_text.body.to_s
        file.rewind

        recruit_document.files.attach(io: file, filename: filename, content_type: 'text/plain')
      end
    rescue => e
      Rails.logger.error "\e[31mMail body cannot be saved due to error: #{e.message}\e[0m"
    end
  end
end
