staff_members = StaffMember.order(:id)

20.times do |n|
  t = (18 -n).weeks.ago.midnight
  Program.create!(
             title: "プログラム No.#{n + 1}",
             description: "会員向け特別プログラムです。" * 10,
             application_start_time: t,
             application_end_time: t.advance(days: 7),
             registrant: staff_members.sample,
             max_number_of_participants: 100,
             min_number_of_participants:   1
  )
end