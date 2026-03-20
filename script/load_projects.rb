require 'yaml'

projects_yaml = YAML.load_file('script/projects.yaml')

puts "=== ЗАГРУЗКА ПРОЕКТОВ В БАЗУ ДАННЫХ ==="
puts ""

created = 0
updated = 0

projects_yaml.each_with_index do |project_data, index|
  project_info = project_data[:project]
  sku = project_info[:sku]

  project = Project.find_or_initialize_by_sku(sku)

  if project.persisted?
    updated += 1
    action = "Обновлен"
  else
    created += 1
    action = "Создан"
  end

  project.assign_attributes(
    name: project_info[:name],
    customer: project_info[:customer],
    address: project_info[:address],
    description: project_info[:description]
  )

  if project.save
    puts "#{index + 1}. #{action}: #{sku} - #{project_info[:name]}"
  else
    puts "#{index + 1}. Ошибка: #{sku} - #{project.errors.full_messages.join(', ')}"
  end
end

puts ""
puts "=== ИТОГО ==="
puts "Создано проектов: #{created}"
puts "Обновлено проектов: #{updated}"
puts "Всего проектов: #{created + updated}"
puts ""
puts "Проверка базы данных..."
puts "Всего проектов в базе: #{Project.count}"
