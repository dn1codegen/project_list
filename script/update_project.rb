project = Project.find_by(sku: "TEST-001")

if project
  project.update!(
    name: "Обновленный тестовый проект",
    customer: "ООО Новое название",
    address: "Санкт-Петербург, Невский пр., 1",
    description: "Обновленное описание проекта"
  )
  puts "Проект успешно обновлен!"
else
  puts "Проект не найден!"
end
