*** Settings ***
Library     RequestsLibrary
Library     JSONLibrary
Library     OperatingSystem
Library     SeleniumLibrary
Library     String
Library     Collections

*** Variables ***
${Url}       https://kitabisa.xyz/register
${qa_url}      http://35.240.132.153:8000
${delay}    2s
${input_email}   xpath://input[@data-testid='register-input-email']
${input_name}      xpath://input[@data-testid='register-input-name']
${daftar}       xpath://button[normalize-space()='Daftar']
${pass}     xpath://input[@data-testid="input-new-password"]
${cpass}    xpath://input[@data-testid="input-confirmation-password"]
${simpan}   xpath://button[contains(text(),'Simpan')]
${kata_sandi_baru}      xpath://span[contains(text(),'Kata Sandi Baru')]
${b_verifikasi}         xpath://button[contains(text(),'Verifikasi')]
${popup_success_verif}  xpath://div[contains(text(),'Verifikasi berhasil')]
${error_invalid_email}  xpath://span[contains(text(),'Hanya diisi dengan nomor ponsel atau email yang valid.')]
${error_invalid_name}   xpath://span[contains(text(),"Nama lengkap hanya boleh huruf, titik (.) dan apos")]
${email_sudah_terdaftar}    xpath://p[@class='text-clrBase mb-0 text-lg font-semibold']
${b_batal}          xpath://button[contains(text(),'Tidak, batal')]
${mulai}            xpath://button[@id='onboarding-onboarding_start']
${kategory_balita}  xpath://p[contains(text(),'Balita & Anak Sakit')]
${kategory_kesehatan}   xpath://p[contains(text(),'Bantuan Medis & Kesehatan')]
${kategory_infrastructur}   xpath://p[contains(text(),'Infrastruktur Umum')]
${b_lanjut}     xpath://button[contains(text(),'Lanjut')]
${aturnanti}    xpath://a[contains(text(),'Atur nanti')]
${skip}    xpath://p[contains(text(),'Tidak. Saya tidak menunaikan zakat')]
${icon_salingjaga}  xpath://div[contains(text(),'Saling Jaga')]
${lanjut}       id:onboarding-onboarding_step2_next
${email}        registerss@gmail.com


*** Keywords ***
Open kitabisa
    Open Browser        ${Url}      Chrome
    Maximize Browser Window


Invalid Email Register
    [Arguments]     ${email}     ${name}    ${hp}
    Input Text      ${input_email}      ${email}
    Input Text      ${input_name}      ${name}
    Wait Until Element Contains     ${error_invalid_email}      Hanya diisi dengan nomor ponsel atau email yang valid.
    Wait Until Element Contains     ${error_invalid_name}       Nama lengkap hanya boleh huruf, titik (.) dan apos
    Clear Element Text      ${input_email}
    Input Text      ${input_email}      ${hp}
    Wait Until Element Contains     ${error_invalid_email}      Hanya diisi dengan nomor ponsel atau email yang valid.
    Clear Element Text      ${input_email}
    Clear Element Text      ${input_name}

Email Sudah Terdaftar 
    [Arguments]     ${email}     ${name}
    Input Text      ${input_email}      ${email}
    Input Text      ${input_name}      ${name}
    Click Element       ${daftar}
    Wait Until Element Is Visible       ${email_sudah_terdaftar}
    Click Element       ${b_batal}
    Clear Element Text      ${input_email}
    Clear Element Text      ${input_name}

Register
    [Arguments]     ${email}     ${name}
    Input Text      ${input_email}      ${email}
    Input Text      ${input_name}      ${name}
    Click Element       ${daftar}

    Sleep   ${delay}

Get OTP
    [Arguments]     ${username}

    ${auth}=    Create List     sdet      k1tab1sa
    Create Session  baseurl     ${qa_url}     auth=${auth}     verify=True
    ${resp}=    Get Request     baseurl     /otp/stg/EMAIL/register/${username}
    
    Should Be Equal As Strings    ${resp.status_code}    200

    ${otp}=    get value from json     ${resp.json()}     $.otp
    ${finalotp}=      Get Substring   s${otp}    3   -2
    Log To Console      ${finalotp}

    [return]    ${finalotp}

    Wait Until Element Is Visible       xpath://h3[normalize-space()='Pastikan kepemilikan akun ini']       30s
    
            FOR    ${otpp}     IN RANGE    1   7
                @{list_otp}=     Convert To List      ${finalotp}
                @{list1}=       Create List     @{list_otp}
                ${abs}=         Set Variable    @{list1}
                ${full_otp}=       Set Variable     xpath://*[@data-testid="input-otp"][${otpp}]
                Wait Until Element Is Visible       ${full_otp}
                FOR     ${abs}      IN RANGE    0   6
                    Input Text      ${full_otp}         ${list1}${abs}

            END
    Click Element       ${b_verifikasi}
    Wait Until Element Contains     ${popup_success_verif}      Verifikasi berhasil

Create New pass
    [Arguments]     ${password}         ${cpassword}
    Wait Until Element Is Visible       ${kata_sandi_baru}      30s
    Input Text       ${pass}     ${password}
    Input Text       ${cpass}    ${cpassword}
    Click Element       ${simpan}

Goto Home Page
    Wait Until Element Is Visible       ${mulai}        30s
    Click Element       ${mulai}
    Wait Until Element Is Visible       ${kategory_balita}
    Click Element       ${kategory_balita}
    Click Element       ${kategory_kesehatan}
    Click Element       ${kategory_infrastructur}
    Click Element       ${b_lanjut}
    Wait Until Element Is Visible       ${aturnanti}
    Click Element       ${aturnanti}
    #Wait Until Element Is Visible       ${aturnanti}
    Sleep   ${delay}
    Click Element       ${skip}
    Click Element       ${b_lanjut}
    Sleep   ${delay}
    Click Element       ${lanjut}
    Wait Until Element Is Visible       ${icon_salingjaga}
    Click Element       ${icon_salingjaga}

    

*** Test Cases ***
open 
    Open kitabisa
    Invalid Email Register   aaagmail.com   0099  09898
    Email Sudah Terdaftar   aada@gmail.com      www
    Register   ${email}       abcs
    Get OTP  ${email}
    Create New pass   qwerqwer      qwerqwer
    Goto Home Page 