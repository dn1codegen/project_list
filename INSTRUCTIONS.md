# Проект управления проектами

Rails 8 приложение для управления проектами с API для клиентской загрузки.

## Стек технологий

- Ruby on Rails 8
- Ruby 3.4.8
- SQLite3
- Active Storage
- CSS (стиль Bootstrap)

## Установка

1. Установите зависимости:
```bash
bundle install
```

2. Настройте базу данных:
```bash
bin/rails db:migrate
```

3. Запустите сервер:
```bash
bin/rails server
```

## Доступ к веб-интерфейсу

**Важно:** Веб-интерфейс защищен токеном доступа.

- Добавьте токен к URL: `http://localhost:3000/?token=secret123`
- По умолчанию токен: `secret123`

### Страницы

- `/?token=secret123` - список проектов с поиском
- `/projects/:id?token=secret123` - детали проекта
- `/api_keys?token=secret123` - управление API ключами

## Создание API ключа

1. Перейдите на `/api_keys?token=secret123`
2. Создайте новый API ключ
3. Используйте ключ в конфигурационном файле клиента

## Отправка проекта через API

### Клиентский скрипт

Скрипт находится в `client/lib/send_project.rb`

### Конфигурация YAML

Создайте файл конфигурации на основе примера:
```bash
cp client/project_config.example.yaml client/project_config.yaml
```

Отредактируйте `client/project_config.yaml`:
```yaml
server_url: "http://localhost:3000"
api_key: "ВАШ_API_КЛЮЧ"

project:
  name: "Название проекта"
  customer: "Заказчик"
  address: "Адрес"
  description: "Описание проекта"

files:
  measurements:
    - path: "замеры/фото1.jpg"
      description: "Описание замера"
  examples:
    - path: "примеры/образец.jpg"
      description: "Описание примера"
  project_pdf:
    path: "проект/план.pdf"
    description: "Последние изменения в проекте"
```

### Запуск скрипта

```bash
cd client
ruby lib/send_project.rb project_config.yaml
```

## Структура файлов клиента

```
client/
├── lib/
│   └── send_project.rb      # Скрипт отправки
├── project_config.yaml      # Ваша конфигурация
├── замеры/                  # Папка с фотографиями замеров
├── примеры/                 # Папка с примерами
└── проект/                  # Папка с PDF файлом проекта
```

## API эндпоинт

**POST** `/api/projects`

Headers:
- `Authorization: Bearer YOUR_API_KEY`

Body (multipart/form-data):
- `project[name]` - название проекта
- `project[customer]` - заказчик
- `project[address]` - адрес
- `project[description]` - описание
- `measurements[][file]` - файлы замеров
- `measurements[][description]` - описания замеров
- `examples[][file]` - файлы примеров
- `examples[][description]` - описания примеров
- `project_pdf[file]` - PDF проекта
- `project_pdf[description]` - описание PDF

## Смена токена доступа

```bash
EDITOR="echo 'app_token: НОВЫЙ_ТОКЕН'" bin/rails credentials:edit
```

Перезапустите сервер после изменения.
