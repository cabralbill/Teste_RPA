*** Settings ***
Documentation       Orders robots from RobotSpareBin Industries Inc.
...                 Saves the order HTML receipt as a PDF file.
...                 Saves the screenshot of the ordered robot.
...                 Embeds the screenshot of the robot to the PDF receipt.
...                 Creates ZIP archive of the receipts and the images
Library             RPA.Browser.Selenium            auto_close=${FALSE}
Library             RPA.HTTP
Library             RPA.Excel.Files
Library             RPA.PDF
Library             String
Library             RPA.Tables
Library             RPA.FileSystem
Library             RPA.Archive


*** Variables ***

${$BOTAO_ORDER}                                id=order
${$BOTAO_PREVIEW}                              id=preview
${IMAGEM_ROBO}                                 id=robot-preview-image
${RECIBO_ROBO}                                 id=receipt
${PDF}                                         PDF


*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Open the intranet website
    Go to Order your robot
    Download the Excel file 
    Fill the form using the data from the CSV file    
    Generate .ZIP   
    Empty the Directory
    Close the Browser


*** keywords ***

Open the intranet website
    Open Available Browser            https://robotsparebinindustries.com    maximized=${True}
    Maximize Browser Window

Go to Order your robot
    Click Element    //a[@class='nav-link'][contains(.,'Order your robot!')]
    Click Element    //button[@type='button'][contains(.,'OK')]


Download the Excel file
    Download    https://robotsparebinindustries.com/orders.csv    overwrite=True


Fill and submit the form for one robot
    [Arguments]                               ${orders}
    Select From List By Value                 head                                  ${orders}[Head]
    Click Element                             id=id-body-${orders}[Body]            
    Input Text                                //input[contains(@type,'number')]     ${orders}[Legs]
    Input Text                                address     ${orders}[Address]        ${orders}[Address]
    Click Button                              preview
    Wait Until Keyword Succeeds               3x    0.3 sec    Click Button        ${$BOTAO_ORDER}
    ${ativo}=    Is Element Enabled           //div[contains(@class,'alert alert-danger')]
    Log           valor de teste ${ativo}
    WHILE    '${ativo}' == '${True}'
        Wait Until Keyword Succeeds           3x    0.3 sec    Click Button        ${$BOTAO_ORDER}
        ${botao}=    Is Element Enabled       order-another
        IF    '${botao}' == '${True}'
            ${ativo}=    Is Element Enabled      //div[contains(@class,'alert alert-danger')]
            Log           valor de teste dentro do IF dentro do while ${ativo}
        END
    END
    Export recibo as a PDF                    ${orders}[Order number]
    Wait Until Keyword Succeeds               3x    0.3 sec    Click Button        order-another    
    Click Element                             //button[@type='button'][contains(.,'OK')]

Fill the form using the data from the CSV file
    ${orders}=      Read table from CSV    orders.csv    header=true
    ${linhas}       ${colunas}        Get Table Dimensions    ${orders}
    ${teste}=        Table Head    ${orders}    ${linhas}
    FOR    ${robot_ins}    IN    @{teste}
        Fill and submit the form for one robot    ${robot_ins}
        Remove File                               ${OUTPUT_DIR}${/}PDF/recibo_${robot_ins}[Order number].png
    END


Export recibo as a PDF
    [Arguments]        ${num}
    Wait Until Element Is Visible                        ${RECIBO_ROBO}
    Screenshot                                           root                                          ${OUTPUT_DIR}${/}PDF/recibo_${num}.png
    ${files}=                                            Create List
    ...    ${OUTPUT_DIR}${/}PDF/recibo_${num}.png
    Add Files To Pdf                                     ${files}                                      ${OUTPUT_DIR}${/}PDF/recibo_robo_${num}.pdf        
    


Generate .ZIP
    ${zip_file_name}=    Set Variable    ${OUTPUT_DIR}/todos.zip
    Archive Folder With Zip
    ...    ${OUTPUT_DIR}/PDF
    ...    ${zip_file_name}


Empty the Directory
    Empty Directory                                      ${OUTPUT_DIR}${/}PDF

Close the Browser
    Close All Browsers