# Shadow-Remote-Control
# RDP Connect Script
Основная идея автоматизация подключения при теневом управлении
## Описание
Скрипт PowerShell для управления удаленным подключением к удаленному рабочему столу (RDP) с использованием mstsc.exe. Скрипт позволяет удобно выбирать пользователя и подключаться к удаленной сессии без необходимости вручную вводить данные каждый раз.

## Требования
- PowerShell 5.1 или выше
- mstsc.exe (клиент удаленного рабочего стола)

## Использование
1. Создайте конфигурационный файл `config.json` рядом со скриптом, в котором определены группы пользователей и их учетные данные.

```json
[
    {
        "GroupName": "Group1",
        "Users": [
            {
                "ComputerName": "PC-NAME",
                "SessionID": 1,
                "Username": "User",
                "Password": "Passuser"
            },
            // Дополнительные пользователи...
        ]
    },
    // Дополнительные группы...
]

Запустите скрипт через ярлык или командную строку:
powershell
powershell.exe -ExecutionPolicy Bypass -File "путь_к_вашему_скрипту.ps1"

Выберите группу пользователя и самого пользователя из выпадающих списков.
Введите пароль (он будет скрыт, но его можно отобразить по кнопке).
Нажмите "Connect" для подключения к удаленному рабочему столу.

Примечания
Перед использованием скрипта убедитесь, что выполнение PowerShell-скриптов разрешено в системе: Set-ExecutionPolicy RemoteSigned.
В случае изменения конфигурации или добавления новых пользователей, просто обновите файл config.json.
