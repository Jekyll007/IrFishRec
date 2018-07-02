function et2
    % закрываем Excel
    system('taskkill /F /IM EXCEL.EXE');
    try
        % чтение матриц с исходными данными из файла
        shetin = xlsread('irfishE.xlsx',1,'B4:E53');
        raznoc = xlsread('irfishE.xlsx',1,'F4:I53');
        virgin = xlsread('irfishE.xlsx',1,'J4:M53');
    catch
        errordlg('Закройте Excel и перезапустите программу');
        return;
    end
    
    % создаём диалог для ввода экземпляра ириса
    nameField = {'Длина чашелистика',...
                 'Ширина чашелистика',...
                 'Длина лепестка',...
                 'Ширина чашелистика'};
    instance = inputdlg(nameField,...
                      'Лаб. №2',...
                      1,...
                      {'5.1','3.5','1.4','0.2'});
    % если нажали отмену - прекращаем всё
    if isempty(instance); return; end    
    % преобразуем введённые данные в массив-строку
    instance = str2double(instance)';
                  
    % создаём меню для выбора метода распознавания
    method = questdlg('Выберите Метод распознавания',...
                      'Метод',...
                      'Ближайшего соседа',...
                      'Потенциалов','Потенциалов');
              
    % распознавание в зависимости от метода
    switch method
        case 'Ближайшего соседа'
            % распознаём
            type = method1(shetin,raznoc,virgin,instance)
        case 'Потенциалов'
            % считываем доп. параметры для метода потенциалов
            nameField = {'v','a','n',};
            paramPot = inputdlg(nameField,...
                                'Параметры',...
                                1,...
                                {'2','2','2'});
            % если нажали отмену - прекращаем всё
            if isempty(instance); return; end
            % преобразуем введённые данные в массив-строку
            paramPot = str2double(paramPot)';
            % распознаём
            type = method2(shetin,raznoc,virgin,instance,...
                           paramPot(1),paramPot(2),paramPot(3));
        otherwise
            return;
    end
    
    % ответ
    switch type
        case 1 
            result = 'ЩЕТИНИСТЫЙ';
        case 2
            result = 'РАЗНОЦВЕТНЫЙ';
        case 3
            result = 'ВИРДЖИНИКА';
    end 
    
    msgbox({'Тип ириса с параметрами' mat2str(instance) result...
            ['Определено методом' method]},'Завершено');
    
% РАСПОЗНАВАНИЕ МЕТОДОМ БЛИЖАЙШЕГО СОСЕДА
% ВХОД:
% shetin - опорная выборка ириса щетинистого
% raznoc - опорная выборка ириса разноцветного
% virgin - опорная выборка ириса вирджиники
% irisX - распознаваемый экземпляр
% ВЫХОД:
% typeOfX - тип ириса (1 или 2 или 3)
function typeOfX = method1(shetin,raznoc,virgin,irisX)
    % вычисляем эталоны для каждого типа
    shetinMean = mean(shetin);
    raznocMean = mean(raznoc);
    virginMean = mean(virgin);
    % вычисляем расстояние от объекта до каждого эталона
    distShetinX = pdist([shetinMean; irisX],'euclidean');
    distRaznocX = pdist([raznocMean; irisX],'euclidean');
    distVirginX = pdist([virginMean; irisX],'euclidean');
    % расстояния до эталонов
    distsToX = [distShetinX distRaznocX distVirginX];
    % ближайший эталон
    [~,typeOfX] = min(distsToX);

    
% РАСПОЗНАВАНИЕ МЕТОДОМ ПОТЕНЦИАЛОВ
% ВХОД:
% shetin - опорная выборка ириса щетинистого
% raznoc - опорная выборка ириса разноцветного
% virgin - опорная выборка ириса вирджиники
% irisX - распознаваемый экземпляр
% nuPot,alphaPot,nPot - параметры метода, подбираемые опытным путём
% ВЫХОД:
% typeOfX - тип ириса (1 или 2 или 3)
function typeOfX = method2(shetin,raznoc,virgin,irisX,nuPot,alphaPot,nPot)
    % вычисляем эталоны для каждого типа
    shetinMean = mean(shetin);
    raznocMean = mean(raznoc);
    virginMean = mean(virgin);
    % вычисляем обобщённое расстояние до каждого эталона
    distShetin = genDist(irisX,shetinMean,nuPot);
    distRaznoc = genDist(irisX,raznocMean,nuPot);
    distVirgin = genDist(irisX,virginMean,nuPot);
    % потенциальная функция
    potShetin = exp(-alphaPot*distShetin^nPot);
    potRaznoc = exp(-alphaPot*distRaznoc^nPot);
    potVirgin = exp(-alphaPot*distVirgin^nPot);
    % потенциалы для распознаваемого объекта
    potForX = [potShetin potRaznoc potVirgin];
    % наибольшее значение функции
    [~,typeOfX] = max(potForX);

    
% ОБОБЩЁННОЕ РАССТОЯНИЕ МЕЖДУ ТОЧКАМИ
% v1 - координаты первой точки
% v2 - координаты второй точки
% nu - параметр метод, подбираемый опытным путём
function dist = genDist(v1,v2,nu)
    sumd = 0;
    for i = 1:length(v1)
        sumd = sumd + abs(v1(i) - v2(i));
    end
    dist = sumd^(1/nu);
    