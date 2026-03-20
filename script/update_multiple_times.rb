project = Project.find_by(sku: "TEST-001")

if project
  5.times do |i|
    project.update!(
      description: "Обновление ##{i + 1} - #{Time.now.strftime('%H:%M:%S')}",
      address: "#{project.address}, кв. #{i + 1}"
    )
    puts "Обновление ##{i + 1} завершено. Текущее количество обновлений: #{project.updates_count}"
  end
else
  puts "Проект не найден!"
end
