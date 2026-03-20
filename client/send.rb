#!/usr/bin/env ruby

# Скрипт для отправки проекта через API
# Использование: ruby send.rb [config.yaml]
# По умолчанию используется: project_config.yaml
# gem install mime-types
#
require 'net/http'
require 'json'
require 'yaml'
require 'uri'
require 'mime/types'
require 'stringio'

class ProjectSender
  def initialize(config_path = 'project_config.yaml')
    @config_path = config_path
    @config = YAML.load_file(config_path)
    @uri = URI.parse("#{@config['server_url']}/api/projects")
  end

  def send
    puts "=== ОТПРАВКА ПРОЕКТА ==="
    puts "Конфигурация: #{@config_path}"
    puts ""

    check_files_exist
    send_project_data
  end

  private

  def check_files_exist
    puts "Проверка файлов..."
    directories_data = @config['directories']
    files_ok = true

    if directories_data
      directories_data.each do |folder_name, folder_config|
        # Обратная совместимость со старым форматом
        if folder_config.is_a?(String)
          # Старый формат: measurements: "замеры"
          folder_config = { 'path' => folder_config, 'title' => folder_name, 'display' => 'grid' }
        end

        folder_path = folder_config['path']
        if folder_path
          files_in_directory(folder_path).each do |file_path|
            unless check_file(file_path)
              files_ok = false
            end
          end
        end
      end
    end

    if files_ok
      puts "✓ Все файлы найдены"
      puts ""
    else
      puts ""
      puts "✗ Некоторые файлы не найдены!"
      exit 1
    end
  end

  def files_in_directory(directory)
    dir_path = File.join(File.dirname(@config_path), directory)
    return [] unless Dir.exist?(dir_path)

    Dir.glob(File.join(dir_path, '*')).reject { |f| File.directory?(f) || f.include?('Zone.Identifier') }
  end

  def find_pdf_in_directory(directory)
    dir_path = File.join(File.dirname(@config_path), directory)
    return nil unless Dir.exist?(dir_path)

    pdf_files = Dir.glob(File.join(dir_path, '*.pdf')).reject { |f| f.include?('Zone.Identifier') }
    pdf_files.empty? ? nil : pdf_files.first
  end

  def check_file(path)
    if File.exist?(path)
      puts "  ✓ #{path}"
      true
    else
      puts "  ✗ #{path} - ФАЙЛ НЕ НАЙДЕН!"
      false
    end
  end

  def send_project_data
    puts "Создание запроса..."
    project_data = @config['project']
    directories_data = @config['directories']

    request = Net::HTTP::Post.new(@uri.request_uri)
    request['Authorization'] = "Bearer #{@config['api_key']}"
    request['Accept'] = 'application/json'

    boundary = "----ProjectSender#{Time.now.to_i}#{rand(10000)}"
    request['Content-Type'] = "multipart/form-data; boundary=#{boundary}"
    request.body = build_multipart_body(boundary, project_data, directories_data)

    puts "Отправка данных на #{@uri}..."
    puts ""

    response = Net::HTTP.start(@uri.host, @uri.port, use_ssl: @uri.scheme == 'https') do |http|
      http.request(request)
    end

    handle_response(response)
  end

  def build_multipart_body(boundary, project_data, directories_data)
    io = StringIO.new
    io.set_encoding(Encoding::ASCII_8BIT)

    # Данные проекта
    io.write("--#{boundary}\r\n")
    io.write('Content-Disposition: form-data; name="project[sku]"' + "\r\n\r\n")
    io.write(project_data['sku'] + "\r\n")

    io.write("--#{boundary}\r\n")
    io.write('Content-Disposition: form-data; name="project[name]"' + "\r\n\r\n")
    io.write(project_data['name'] + "\r\n")

    io.write("--#{boundary}\r\n")
    io.write('Content-Disposition: form-data; name="project[customer]"' + "\r\n\r\n")
    io.write(project_data['customer'] + "\r\n")

    io.write("--#{boundary}\r\n")
    io.write('Content-Disposition: form-data; name="project[address]"' + "\r\n\r\n")
    io.write(project_data['address'] + "\r\n")

    io.write("--#{boundary}\r\n")
    io.write('Content-Disposition: form-data; name="project[description]"' + "\r\n\r\n")
    io.write(project_data['description'].to_s + "\r\n")

    # Динамическая обработка всех папок
    if directories_data
      directories_data.each do |folder_name, folder_config|
        # Обратная совместимость со старым форматом
        if folder_config.is_a?(String)
          # Старый формат: measurements: "замеры"
          folder_path = folder_config
          folder_title = folder_name
          folder_display = folder_name == 'project_pdf' ? 'list' : 'grid'
        else
          # Новый формат: замеры: { path: "замеры", title: "Замеры", display: "grid" }
          folder_path = folder_config['path']
          folder_title = folder_config['title'] || folder_name
          folder_display = folder_config['display'] || 'grid'
        end

        next unless folder_path

        # Получение файлов из папки
        files = files_in_directory(folder_path)

        # Отправка каждого файла
        files.each_with_index do |file_path, index|
          description = get_filename_without_extension(file_path)

          add_file_with_type_to_io(
            io,
            boundary,
            "files[#{folder_name}][#{index}][file]",
            file_path,
            "files[#{folder_name}][#{index}][description]",
            description,
            "files[#{folder_name}][#{index}][folder_name]",
            folder_name,
            "files[#{folder_name}][#{index}][folder_title]",
            folder_title,
            "files[#{folder_name}][#{index}][display]",
            folder_display
          )
        end
      end
    end

    io.write("--#{boundary}--\r\n")

    io.string
  end

  def add_file_with_type_to_io(io, boundary, file_field_name, file_path, desc_field_name, description, type_field_name, folder_name, title_field_name, folder_title, display_field_name, folder_display)
    filename = File.basename(file_path)
    mime_type = MIME::Types.type_for(filename).first || 'application/octet-stream'
    file_content = File.binread(file_path)

    io.write("--#{boundary}\r\n")
    io.write("Content-Disposition: form-data; name=\"#{file_field_name}\"; filename=\"#{filename}\"\r\n")
    io.write("Content-Type: #{mime_type}\r\n\r\n")
    io.write(file_content)
    io.write("\r\n")

    if description
      io.write("--#{boundary}\r\n")
      io.write("Content-Disposition: form-data; name=\"#{desc_field_name}\"\r\n\r\n")
      io.write(description.to_s + "\r\n")
    end

    if folder_name
      io.write("--#{boundary}\r\n")
      io.write("Content-Disposition: form-data; name=\"#{type_field_name}\"\r\n\r\n")
      io.write(folder_name.to_s + "\r\n")
    end

    if folder_title
      io.write("--#{boundary}\r\n")
      io.write("Content-Disposition: form-data; name=\"#{title_field_name}\"\r\n\r\n")
      io.write(folder_title.to_s + "\r\n")
    end

    if folder_display
      io.write("--#{boundary}\r\n")
      io.write("Content-Disposition: form-data; name=\"#{display_field_name}\"\r\n\r\n")
      io.write(folder_display.to_s + "\r\n")
    end
  end

  def get_filename_without_extension(path)
    filename = File.basename(path)
    filename.sub(/\.[^.]+\z/, '')
  end

  def handle_response(response)
    puts "Статус ответа: #{response.code} #{response.message}"

    case response.code
    when '200', '201'
      data = JSON.parse(response.body)
      action = data['updated'] ? 'обновлён' : 'создан'
      puts ""
      puts "✓ Проект успешно #{action}!"
      puts "  ID проекта: #{data['project_id']}"
      puts "  Артикул: #{@config['project']['sku']}"
      puts "  Название: #{@config['project']['name']}"
    else
      puts ""
      puts "✗ Ошибка:"
      puts response.body
      exit 1
    end
  end
end

# Точка входа
if __FILE__ == $0
  config_path = ARGV[0] || 'project_config.yaml'

  unless File.exist?(config_path)
    puts "Ошибка: Файл конфигурации не найден: #{config_path}"
    puts ""
    puts "Использование:"
    puts "  ruby send.rb [путь_к_конфигурации.yaml]"
    puts ""
    puts "По умолчанию используется: project_config.yaml"
    exit 1
  end

  sender = ProjectSender.new(config_path)
  sender.send
end
