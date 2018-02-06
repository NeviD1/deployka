///////////////////////////////////////////////////////////////////////////////////////////////////
// Прикладной интерфейс
Перем Лог;
Перем ЭтоWindows;

Процедура ЗарегистрироватьКоманду(Знач ИмяКоманды, Знач Парсер) Экспорт
	
    ОписаниеКоманды = Парсер.ОписаниеКоманды(ИмяКоманды, "Управление запуском в режиме предприятия");
    Парсер.ДобавитьПозиционныйПараметрКоманды(ОписаниеКоманды, "СтрокаПодключения", "Строка подключения к рабочему контуру");
    Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, 
    	"-db-user",
    	"Пользователь информационной базы");

    Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, 
    	"-db-pwd",
    	"Пароль пользователя информационной базы");

    Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, 
    	"-v8version",
    	"Маска версии платформы 1С");
	
	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, 
    	"-uccode",
    	"Ключ разрешения запуска");
	
	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, 
		"-command", 
		"Строка передаваемя в ПараметрыЗапуска, /C''");
		
	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, 
		"-execute", 
		"Путь обработки для запуска");

	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, 
		"-additional", 
		"Дополнительные ключи запуска 1С");

	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды,
		"-log", 
		"Лог-файл для вывода сообщений платформы. В итоге, задает ключ запуска /Out.");

	Парсер.ДобавитьПараметрФлагКоманды(ОписаниеКоманды, 
		"-thin-client", 
		"Запускать тонкий клиент принудительно");

    Парсер.ДобавитьКоманду(ОписаниеКоманды);
    
КонецПроцедуры

Функция ВыполнитьКоманду(Знач ПараметрыКоманды) Экспорт
	ВозможныйРезультат = МенеджерКомандПриложения.РезультатыКоманд();
	
    СтрокаПодключения = ПараметрыКоманды["СтрокаПодключения"];
	Пользователь      = ПараметрыКоманды["-db-user"];
	Пароль            = ПараметрыКоманды["-db-pwd"];
	ИспользуемаяВерсияПлатформы = ПараметрыКоманды["-v8version"];
	КлючРазрешенияЗапуска       = ПараметрыКоманды["-uccode"];
	ПараметрЗапускаПредприятия  = ПараметрыКоманды["-command"];
	ОбработкаДляЗапуска         = ПараметрыКоманды["-execute"];
	ЛогФайл         			= ПараметрыКоманды["-log"];
	
	Если ПустаяСтрока(СтрокаПодключения) Тогда
		Лог.Ошибка("Не задана строка подключения");
		Возврат ВозможныйРезультат.НеверныеПараметры;
	КонецЕсли;
	
	Конфигуратор = ЗапускПриложений.НастроитьКонфигуратор(
		СтрокаПодключения,
		Пользователь,
		Пароль,
		ИспользуемаяВерсияПлатформы);

	Если ПараметрыКоманды["-thin-client"] Тогда
		Конфигуратор.ПутьКПлатформе1С(Конфигуратор.ПутьКТонкомуКлиенту1С());
	КонецЕслИ;
	
	Если Не ПустаяСтрока(КлючРазрешенияЗапуска) Тогда
		Конфигуратор.УстановитьКлючРазрешенияЗапуска(КлючРазрешенияЗапуска);
	КонецЕсли;
	
	Если ПараметрЗапускаПредприятия = Неопределено Тогда 
		ПараметрЗапускаПредприятия = "";
	КонецЕсли;
	
	ДополнительныеКлючи = ""+ ПараметрыКоманды["-additional"] + " ";
	Если Не ПустаяСтрока(ОбработкаДляЗапуска) Тогда
		ДополнительныеКлючи = ДополнительныеКлючи + "/Execute"+ЗапускПриложений.ОбернутьВКавычки(ОбработкаДляЗапуска);
	КонецЕсли;
	
	Если Не ПустаяСтрока(ЛогФайл) Тогда
		Конфигуратор.УстановитьИмяФайлаСообщенийПлатформы(ЛогФайл);
	КонецЕсли;

	Лог.Информация("Запускаю в режиме предприятия");
	Попытка
		Конфигуратор.УстановитьОбработчикОжидания(ЭтотОбъект);
		Конфигуратор.ЗапуститьВРежимеПредприятия(ПараметрЗапускаПредприятия, Неопределено, ДополнительныеКлючи);
		Текст = Конфигуратор.ВыводКоманды();
		Если Не ПустаяСтрока(Текст) Тогда
			Лог.Информация(Текст);
		КонецЕсли;
	Исключение
		Лог.Ошибка(ОписаниеОшибки());
		Возврат ВозможныйРезультат.ОшибкаВремениВыполнения;
	КонецПопытки;
	
	Возврат ВозможныйРезультат.Успех;
    
КонецФункции

Процедура ОбработкаОжиданияПроцесса(Отказ, Интервал) Экспорт
	Лог.Отладка("Ожидаю завершения процесса 1С...");
	Если Интервал < 60000 Тогда
		Интервал = Интервал + 500;
	КонецЕсли;
КонецПроцедуры

/////////////////////////////////////////////////////////////////////////////////
СистемнаяИнформация = Новый СистемнаяИнформация;
ЭтоWindows = Найти(НРег(СистемнаяИнформация.ВерсияОС), "windows") > 0;
Лог = Логирование.ПолучитьЛог("vanessa.app.deployka");