project = Project.find_by(sku: "TEST-001")

if project
  puts "Найден проект: #{project.name}"
  puts "Загрузка файлов..."

  # Загрузка замеров (measurements)
  measurements_dir = "client/замеры"
  if Dir.exist?(measurements_dir)
    Dir.glob("#{measurements_dir}/*").each do |file_path|
      next if File.directory?(file_path)

      file = File.open(file_path)
      filename = File.basename(file_path)

      project_file = project.measurements.find_or_create_by(
        description: filename
      )

      if project_file.file.attached?
        project_file.file.purge
      end

      project_file.file.attach(
        io: file,
        filename: filename
      )
      file.close

      puts "  ✓ Загружен замер: #{filename}"
    end
  else
    puts "  ✗ Папка замеров не найдена"
  end

  # Загрузка проекта (project_pdf)
  project_dir = "client/проект"
  if Dir.exist?(project_dir)
    Dir.glob("#{project_dir}/*").each do |file_path|
      next if File.directory?(file_path)

      file = File.open(file_path)
      filename = File.basename(file_path)

      project_pdf = project.project_pdf || project.project_files.create!(file_type: "project_pdf")

      if project_pdf.file.attached?
        project_pdf.file.purge
      end

      project_pdf.file.attach(
        io: file,
        filename: filename
      )
      file.close

      puts "  ✓ Загружен проект: #{filename}"
    end
  else
    puts "  ✗ Папка проекта не найдена"
  end

  # Загрузка примеров (examples)
  examples_dir = "client/примеры"
  if Dir.exist?(examples_dir)
    Dir.glob("#{examples_dir}/*").each do |file_path|
      next if File.directory?(file_path)
      next if file_path.include?("Zone.Identifier")

      file = File.open(file_path)
      filename = File.basename(file_path)

      example_file = project.examples.find_or_create_by(
        description: filename
      )

      if example_file.file.attached?
        example_file.file.purge
      end

      example_file.file.attach(
        io: file,
        filename: filename
      )
      file.close

      puts "  ✓ Загружен пример: #{filename}"
    end
  else
    puts "  ✗ Папка примеров не найдена"
  end

  # Обновление данных проекта
  puts "\nОбновление данных проекта..."

  project.update!(
    description: "Проект с загруженными файлами (замеры: #{project.measurements.count}, примеры: #{project.examples.count})",
    address: "Обновленный адрес с данными о проекте"
  )

  puts "\nФинальное состояние проекта:"
  puts "  Название: #{project.name}"
  puts "  Заказчик: #{project.customer}"
  puts "  Адрес: #{project.address}"
  puts "  Описание: #{project.description}"
  puts "  SKU: #{project.sku}"
  puts "  Количество обновлений: #{project.updates_count}"
  puts "  Замеры: #{project.measurements.count} файлов"
  puts "  Примеры: #{project.examples.count} файлов"
  puts "  Проект (PDF): #{project.project_pdf&.file&.attached? ? 'Загружен' : 'Не загружен'}"

else
  puts "Проект не найден!"
end
