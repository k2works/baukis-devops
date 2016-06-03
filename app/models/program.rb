class Program < ActiveRecord::Base
  has_many :entries, dependent: :destroy
  has_many :applicants, through: :entries, source: :customer
  belongs_to :registrant, class_name: 'StaffMember'

  scope :listing, -> {
    joins('LEFT JOIN entries ON programs.id = entries.program_id')
    .select('programs.*, COUNT(entries.id) AS number_of_applicants')
        .group('programs.id')
        .order(application_start_time: :desc)
        .includes(:registrant)
  }
end
