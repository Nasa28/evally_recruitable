# frozen_string_literal: true

module V2
  module RecruitDocuments
    class Serializer < Blueprinter::Base
      identifier :id

      fields :first_name, :last_name, :gender, :email, :phone, :group, :position, :source,
             :received_at, :accept_current_processing, :accept_future_processing,
             :public_recruit_id, :task_sent_at, :call_scheduled_at, :interview_scheduled_at,
             :incomplete_details, :rejection_reason, :evaluator_id, :social_links, :salary,
             :availability, :available_since, :location, :contract_type, :work_type, :message

      field :status do |recruit_document|
        status_item = V2::RecruitDocuments::StatusManagerService.find(recruit_document.status)

        V2::RecruitDocuments::StatusSerializer.render_as_hash(status_item)
      end
    end
  end
end
