local L = LibStub("AceLocale-3.0"):NewLocale("MapHighlights", "ruRU")
if not L then return end
-- Translator ZamestoTV
L["enable"] = "Включить"
L["scale"] = "Масштаб"
L["alpha"] = "Прозрачность"
L["textFont"] = "Шрифт текста"
L["textSize"] = "Размер текста"
L["show"] = "Показать"
L["enableColor"] = "Включить цвет"
L["text"] = "Текст"
L["highlight"] = "Подсветка"
L["animation"] = "Анимация"
L["color"] = "Цвет"
L["top"] = "Верх"
L["bottom"] = "Низ"
L["left"] = "Слева"
L["right"] = "Справа"
L["center"] = "Центр"
L["offset"] = "Смещение"
L["glow"] = "Свечение"
L["openOptions"] = "Открыть настройки"

-- Main menu
L["tab_settings"] = "Настройки"
L["tab_mapHighlights"] = "Подсветка карты"
L["tab_other"] = "Другие параметры"

-- map highlights
--
-- global settings
L["header_globalHighlights"] = "Глобальные настройки подсветки"
L["descr_globalHighlights"] = "Эти настройки применяются ко всем элементам подсветки карты.|nОни могут быть переопределены индивидуальными настройками каждой подсветки."
L["dropdown_textOutline"] = "Контур текста"
L["outlineNone"] = "Нет"
L["outlineThin"] = "Тонкий"
L["outlineThick"] = "Толстый"
--
-- individual settings
L["header_hlSelection"] = "Индивидуальные настройки подсветки"
L["header_animation"] = "Анимация"
L["descr_anim"] = "Нажмите на область предпросмотра, чтобы запустить анимацию"
L["dropdown_animPlayback"] = "Когда воспроизводить анимацию"
L["animPlayback_onBoth"] = "При открытии карты и нажатии"
L["animPlayback_onMap"] = "Только при открытии карты"
L["animPlayback_onClick"] = "Только при нажатии"
L["animPlayback_loop"] = "Циклично"

L["dropdown_animStyle"] = "Стиль анимации"
L["animStyle1"] = "Сжатие и затухание"
L["animStyle2"] = "Увеличение и затухание"
L["animStyle3"] = "Пульсация"
L["animStyle4"] = "Мигание"

L["iconScale"] = "Масштаб подсветки"
L["dropdown_hlStyle"] = "Стиль подсветки"
L["hlStyle_glowingFG"] = "Светящийся передний план"
L["hlStyle_solidBG"] = "Сплошной фон"
L["hlStyle_glowingBG"] = "Светящийся фон"

L["dropdown_hlTexture"] = "Текстура подсветки"
L["hlTexture_1"] = "Как у иконки"
L["hlTexture_2"] = "Мягкий круг"
L["hlTexture_3"] = "Сплошной желтый круг"
L["hlTexture_4"] = "Сплошной коричневый круг"

L["textScale"] = "Масштаб текста"
L["textPosition"] = "Положение текста"
L["textCustom"] = "Настройка шрифта"
L["textLevel"] = "Слой текста"
L["descr_textLevel"] = "Более высокие значения позволяют тексту перекрывать другие иконки.|n|nЗначения 2200–2800 обычно оптимальны.|nЗначения выше 2800 будут перекрывать стрелку игрока."

-- highlight group names
L["Navigation"] = "Навигация"
L["Locations"] = "Места"
L["Objectives"] = "Задачи"
L["Other"] = "Прочее"
-- highlight names
L["Waypoint"] = "Точка пути"
L["Flightmaster"] = "Распорядитель полетов"
L["Flightmaster (undiscovered)"] = "Распорядитель полетов (не открыт)"
L["Dungeon"] = "Подземелье"
L["Raid"] = "Рейд"
L["Lair"] = "Логово"
L["Delve"] = "Вылазка"
L["Bountiful Delve"] = "Многообещающая вылазка"
L["Quest Hub"] = "Квестовый узел"
L["Zone Portal"] = "Портал в зону"
L["Cave Exit (Up)"] = "Выход из пещеры (вверх)"
L["Cave Exit (Down)"] = "Выход из пещеры (вниз)"
L["Rare Encounter"] = "Редкое существо"
L["WQ Special Assignment"] = "ЛЗ: Особое поручение"
L["S.C.R.A.P. Heap (active)"] = "Гора ХЛАМа (активна)"
L["S.C.R.A.P. Heap (inactive)"] = "Гора ХЛАМа (неактивна)"
L["Treasure Goblin Spawn"] = "Появление алчного гоблина"
L["Ritual Site"] = "Место ритуала"

L["checkbox_playerLocation"] = "Подсветка игрока"
L["descr_playerLocation"] = "Подсвечивает стрелку вашего местоположения при открытии карты и нажатии кнопки мыши."
L["checkbox_battlefieldMap"] = "Включить миникарту поля боя"
L["descr_battlefieldMap"] = "Все элементы подсветки будут отображаться не только на карте мира, но и на миникарте поля боя."

L["chatCommands"] = "Команды чата:"
L["preview"] = "Предпросмотр"
L["disabled"] = "Отключено"

L["header_playerLocation"] = "Подсветка местоположения игрока"
L["header_playerDirection"] = "Линия направления игрока"
L["header_misc"] = "Разное"
L["descr_playerDirection"] = "Рисует линию от игрока в том направлении, куда он смотрит."
L["never"] = "Никогда"
L["always"] = "Всегда"
L["whileFlying"] = "Только во время полета"
L["colorStart"] = "Начало"
L["colorEnd"] = "Конец"
L["length"] = "Длина"
L["thickness"] = "Толщина"

L["Custom"] = "Свои" -- new highlights that the user added
L["new"] = "Создать" -- add new custom highlight
L["rename"] = "Переименовать" -- rename custom highlight
L["delete"] = "Удалить" -- delete custom highlight
L["copy"] = "Копировать настройки из ..." -- copy settings from one highlight to the current one
L["outlineThinOld"] = "Тонкий (старый)"
L["outlineThickOld"] = "Толстый (старый)"
