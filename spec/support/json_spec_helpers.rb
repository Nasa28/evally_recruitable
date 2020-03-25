# frozen_string_literal: true

# rubocop:disable Metrics/MethodLength, Metrics/AbcSize

module JsonSpecHelpers
  def recruit_document_schema(recruit_document)
    {
      id: recruit_document.id,
      status: status_schema(recruit_document.status),
      first_name: recruit_document.first_name,
      last_name: recruit_document.last_name,
      gender: recruit_document.gender,
      email: recruit_document.email,
      phone: recruit_document.phone,
      group: recruit_document.group,
      position: recruit_document.position,
      received_at: recruit_document.received_at.to_s,
      source: recruit_document.source,
      accept_current_processing: recruit_document.accept_current_processing,
      accept_future_processing: recruit_document.accept_future_processing,
      public_recruit_id: Digest::SHA256.hexdigest(recruit_document.email)
    }.to_json
  end

  def required_field_schema(field)
    {
      value: field.value,
      label: field.label,
      type: field.type
    }
  end

  def status_schema(status)
    status_item = RecruitDocuments::StatusesManagerService.find(status)

    {
      value: status_item.value,
      color: status_item.color,
      label: status_item.label,
      required_fields: status_item.required_fields.map(&method(:required_field_schema))
    }
  end
end

# rubocop:enable Metrics/MethodLength, Metrics/AbcSize

RSpec.configure do |config|
  config.include JsonSpecHelpers, type: :controller
end
