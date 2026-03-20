project = Project.find_by(sku: "TEST-001")

if project
  updates = [
    { name: "Проект Версия 2", description: "Добавлены новые требования" },
    { customer: "ЗАО Технологии", description: "Сменен заказчик" },
    { address: "Москва, ул. Ленина, 45", description: "Обновлен адрес" },
    { name: "Проект Версия 3", description: "Финальная версия" },
    { description: "Дополнительные правки завершены", address: "Москва, ул. Ленина, 45, оф. 101" }
  ]

  updates.each_with_index do |update_data, index|
    project.update!(update_data)
    puts "Обновление ##{index + 1}: #{update_data.values.first}"
    puts "  Текущее количество обновлений: #{project.updates_count}"
    sleep 0.5
  end

  puts "\nФинальное состояние проекта:"
  puts "  Название: #{project.name}"
  puts "  Заказчик: #{project.customer}"
  puts "  Адрес: #{project.address}"
  puts "  Описание: #{project.description}"
  puts "  SKU: #{project.sku}"
  puts "  Количество обновлений: #{project.updates_count}"
else
  puts "Проект не найден!"
end
