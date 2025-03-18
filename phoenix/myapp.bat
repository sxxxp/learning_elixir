@echo off
setlocal enabledelayedexpansion

set "elixir_version=1.17.3"
set "otp_version=27.1.2"
set "otp_release=27"
set "elixir_install_root=%USERPROFILE%\.elixir-install"

if not exist "%elixir_install_root%" (
    mkdir "%elixir_install_root%"
)

curl.exe -fsSo "%elixir_install_root%\install.bat" https://elixir-lang.org/install.bat
call "%elixir_install_root%\install.bat" elixir@%elixir_version% otp@%otp_version%
set "PATH=%elixir_install_root%\installs\elixir\%elixir_version%-otp-%otp_release%\bin;%elixir_install_root%\installs\otp\%otp_version%\bin;%PATH%"

REM Use 'mix' to install 'phx_new' archive
where mix >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo Error: mix command not found.
    exit /b 1
)

REM call :echo_heading "Installing phx_new archive..."
call mix.bat archive.install hex phx_new --force

REM Set app_name
set "app_name=myapp"

REM Get app_args
shift /1
set "app_args=%*"

REM Determine db_option
set "db_option="

where psql >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo Postgres is installed. Using Postgres for the Ecto adapter.
) else (
    where mysql >nul 2>&1
    if %ERRORLEVEL% EQU 0 (
        echo MySQL is installed. Using MySQL for the Ecto adapter.
        set "db_option=--database mysql"
    ) else (
        echo Using SQLite for the Ecto adapter.
        set "db_option=--database sqlite3"
    )
)

REM Check if Git is installed by attempting to get the version
git --version >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo Git is not installed. Installing via winget...
    winget install --id Git.Git -e --source winget
    IF %ERRORLEVEL% NEQ 0 (
        echo Failed to install Git. Please ensure winget is installed and try again.
        exit /b 1
    )
    echo Refreshing environment variables to make Git available...
    REM Refresh the PATH variable for the current shell
    set "Path=%Path%;C:\Program Files\Git\cmd"
    echo Git has been installed successfully.
)
REM Verify Git is now available
git --version
IF %ERRORLEVEL% NEQ 0 (
    echo Git is still not available. Please restart the shell or check your PATH settings.
    exit /b 1
)

call :echo_heading "Creating new Phoenix project '%app_name%'..."
call mix.bat phx.new "%app_name%" !db_option! %app_args% --install --from-elixir-install

call :echo_heading "%app_name% created. Starting Phoenix server..."
cd "%app_name%"
call mix.bat setup
call mix.bat phx.server --open

exit /b 0

:echo_heading
echo.
echo %~1
echo.
exit /b 0
