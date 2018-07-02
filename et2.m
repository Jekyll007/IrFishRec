function et2
    % ��������� Excel
    system('taskkill /F /IM EXCEL.EXE');
    try
        % ������ ������ � ��������� ������� �� �����
        shetin = xlsread('irfishE.xlsx',1,'B4:E53');
        raznoc = xlsread('irfishE.xlsx',1,'F4:I53');
        virgin = xlsread('irfishE.xlsx',1,'J4:M53');
    catch
        errordlg('�������� Excel � ������������� ���������');
        return;
    end
    
    % ������ ������ ��� ����� ���������� �����
    nameField = {'����� �����������',...
                 '������ �����������',...
                 '����� ��������',...
                 '������ �����������'};
    instance = inputdlg(nameField,...
                      '���. �2',...
                      1,...
                      {'5.1','3.5','1.4','0.2'});
    % ���� ������ ������ - ���������� ��
    if isempty(instance); return; end    
    % ����������� �������� ������ � ������-������
    instance = str2double(instance)';
                  
    % ������ ���� ��� ������ ������ �������������
    method = questdlg('�������� ����� �������������',...
                      '�����',...
                      '���������� ������',...
                      '�����������','�����������');
              
    % ������������� � ����������� �� ������
    switch method
        case '���������� ������'
            % ���������
            type = method1(shetin,raznoc,virgin,instance)
        case '�����������'
            % ��������� ���. ��������� ��� ������ �����������
            nameField = {'v','a','n',};
            paramPot = inputdlg(nameField,...
                                '���������',...
                                1,...
                                {'2','2','2'});
            % ���� ������ ������ - ���������� ��
            if isempty(instance); return; end
            % ����������� �������� ������ � ������-������
            paramPot = str2double(paramPot)';
            % ���������
            type = method2(shetin,raznoc,virgin,instance,...
                           paramPot(1),paramPot(2),paramPot(3));
        otherwise
            return;
    end
    
    % �����
    switch type
        case 1 
            result = '����������';
        case 2
            result = '������������';
        case 3
            result = '����������';
    end 
    
    msgbox({'��� ����� � �����������' mat2str(instance) result...
            ['���������� �������' method]},'���������');
    
% ������������� ������� ���������� ������
% ����:
% shetin - ������� ������� ����� �����������
% raznoc - ������� ������� ����� �������������
% virgin - ������� ������� ����� ����������
% irisX - �������������� ���������
% �����:
% typeOfX - ��� ����� (1 ��� 2 ��� 3)
function typeOfX = method1(shetin,raznoc,virgin,irisX)
    % ��������� ������� ��� ������� ����
    shetinMean = mean(shetin);
    raznocMean = mean(raznoc);
    virginMean = mean(virgin);
    % ��������� ���������� �� ������� �� ������� �������
    distShetinX = pdist([shetinMean; irisX],'euclidean');
    distRaznocX = pdist([raznocMean; irisX],'euclidean');
    distVirginX = pdist([virginMean; irisX],'euclidean');
    % ���������� �� ��������
    distsToX = [distShetinX distRaznocX distVirginX];
    % ��������� ������
    [~,typeOfX] = min(distsToX);

    
% ������������� ������� �����������
% ����:
% shetin - ������� ������� ����� �����������
% raznoc - ������� ������� ����� �������������
% virgin - ������� ������� ����� ����������
% irisX - �������������� ���������
% nuPot,alphaPot,nPot - ��������� ������, ����������� ������� ����
% �����:
% typeOfX - ��� ����� (1 ��� 2 ��� 3)
function typeOfX = method2(shetin,raznoc,virgin,irisX,nuPot,alphaPot,nPot)
    % ��������� ������� ��� ������� ����
    shetinMean = mean(shetin);
    raznocMean = mean(raznoc);
    virginMean = mean(virgin);
    % ��������� ���������� ���������� �� ������� �������
    distShetin = genDist(irisX,shetinMean,nuPot);
    distRaznoc = genDist(irisX,raznocMean,nuPot);
    distVirgin = genDist(irisX,virginMean,nuPot);
    % ������������� �������
    potShetin = exp(-alphaPot*distShetin^nPot);
    potRaznoc = exp(-alphaPot*distRaznoc^nPot);
    potVirgin = exp(-alphaPot*distVirgin^nPot);
    % ���������� ��� ��������������� �������
    potForX = [potShetin potRaznoc potVirgin];
    % ���������� �������� �������
    [~,typeOfX] = max(potForX);

    
% ����٨���� ���������� ����� �������
% v1 - ���������� ������ �����
% v2 - ���������� ������ �����
% nu - �������� �����, ����������� ������� ����
function dist = genDist(v1,v2,nu)
    sumd = 0;
    for i = 1:length(v1)
        sumd = sumd + abs(v1(i) - v2(i));
    end
    dist = sumd^(1/nu);
    