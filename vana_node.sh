#!/bin/bash

tput reset
tput civis

# Put your logo here if nessesary

show_orange() {
    echo -e "\e[33m$1\e[0m"
}

show_blue() {
    echo -e "\e[34m$1\e[0m"
}

show_green() {
    echo -e "\e[32m$1\e[0m"
}

show_red() {
    echo -e "\e[31m$1\e[0m"
}

exit_script() {
    show_red "Скрипт остановлен (Script stopped)"
        echo ""
        exit 0
}

incorrect_option () {
    echo ""
    show_red "Неверная опция. Пожалуйста, выберите из тех, что есть."
    echo ""
    show_red "Invalid option. Please choose from the available options."
    echo ""
}

process_notification() {
    local message="$1"
    show_orange "$message"
    sleep 1
}

run_commands() {
    local commands="$*"

    if eval "$commands"; then
        sleep 1
        echo ""
        show_green "Успешно (Success)"
        echo ""
    else
        sleep 1
        echo ""
        show_red "Ошибка (Fail)"
        echo ""
    fi
}

version_ge() {
    [ "$(printf '%s\n' "$1" "$2" | sort -V | head -n1)" = "$2" ]
}

show_orange " ____    ____      ___      .__   __.      ___ " && sleep 0.2
show_orange " \   \  /   /     /   \     |  \ |  |     /   \ " && sleep 0.2
show_orange "  \   \/   /     /  ^  \    |   \|  |    /  ^  \ " && sleep 0.2
show_orange "   \      /     /  /_\  \   |  .    |   /  /_\  \ " && sleep 0.2
show_orange "    \    /     /  _____  \  |  |\   |  /  _____  \ " && sleep 0.2
show_orange "     \__/     /__/     \__\ |__| \__| /__/     \__\ " && sleep 0.2
echo ""
sleep 1

while true; do
    echo "1. Подготовка к установке VANA (Preparation)"
    echo "2. Установить VANA (Installation)"
    echo "3. Создать/Восстановить кошельки (Create/Restore Wallets)"
    echo "4. Деплой контракта в MOKSHA (Deploy)"
    echo "5. Установить/восстановить Валидатора (Install/Restore Validator)"
    echo "6. Запуск/остановка/перезапуск (Start/stop/restart)"
    echo "7. Проверить логи (Check Logs)"
    echo "8. Восстановить (Restore)"
    echo "9. Обновить (Update)"
    echo "10. Удалить ноду (Delete node)"
    echo "11. Выход (Exit)"
    echo ""
    read -p "Выберите опцию (Select option): " option

    case $option in
        1)
            #  PREPARATION
            process_notification "Начинаем подготовку (Starting preparation)..."
            run_commands "cd $HOME && sudo apt update && sudo apt upgrade -y && sudo apt-get install git -y && sudo apt install -y unzip nano"

            #  Python installation
            process_notification "Устанавливаем Python (Installing Python)..."
            sudo apt install -y software-properties-common && \
            sudo add-apt-repository ppa:deadsnakes/ppa && \
            sudo apt update && apt install python3.11 -y
            PYTHON_VERSION=$(python3.11 --version 2>&1)
            if [[ "$PYTHON_VERSION" == "Python 3.11.10" ]]; then
                sleep 1
                echo ""
                show_green "Python 3.11.10. Успешно (Success)"
                echo ""
            else
                sleep 1
                echo ""
                show_red "Ошибка (Fail)"
                echo ""
            fi

            #  POETRY installation
            process_notification "Устанавливаем Poetry (Installing Poetry)..."
            sudo apt install python3-pip python3-venv curl -y
            curl -sSL https://install.python-poetry.org | python3 -
            sed -i '1i export PATH="/root/.local/bin:$PATH"' "$HOME/.bashrc"
            export PATH="/root/.local/bin:$PATH"
            source $HOME/.bashrc

            POETRY_VERSION=$(poetry --version 2>&1)
            if [[ "$POETRY_VERSION" == Poetry* ]]; then
                sleep 1
                echo ""
                show_green "$POETRY_VERSION Успешно (Success)"
                echo ""
            else
                sleep 1
                echo ""
                show_red "Ошибка (Fail). Poetry не установлен (not installed)"
                echo ""
            fi

            #  Node.js and npm installation
            process_notification "Чистим (Clear) Nodejs Libnode-dev "
            run_commands "apt remove -y nodejs && sudo apt remove -y libnode-dev && sudo apt clean"

            process_notification "Устанавливаем Node.js и npm (Installing Node.js and npm)..."
            curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
            sudo apt install -y nodejs

            # curl -fsSL https://fnm.vercel.app/install | bash
            # source ~/.bashrc | bash
            # fnm use --install-if-missing 22

            NODE_VERSION=$(node -v 2>&1 | sed 's/v//')
            NPM_VERSION=$(npm -v 2>&1)

            MIN_NODE_VERSION="22.9.0"
            MIN_NPM_VERSION="10.8.3"

            run_commands "version_ge \"$NODE_VERSION\" \"$MIN_NODE_VERSION\" && version_ge \"$NPM_VERSION\" \"$MIN_NPM_VERSION\""

            #  Installing dependencies
            process_notification "Устанавливаем зависимости (Installing dependencies)..."
            run_commands "npm install -g yarn"

            if YARN_VERSION=$(yarn --version 2>&1); then
                sleep 1
                echo ""
                show_green "Yarn установлен (installed)"
                echo ""
            else
                sleep 1
                echo ""
                show_red "Yarn ошибка"
                echo ""
            fi

            echo ""
            show_green "--- ПОДГОТОВКА ЗАВЕРШЕНА. PREPARATION COMPLETED ---"
            echo ""
            ;;
        2)
            #  INSTALLATION
            process_notification "Начинаем установку (Starting installation)..."
            echo ""
            sleep 1

            process_notification "Клонируем репозиторий (Clone Repo)..."
            run_commands "cd $HOME && git clone https://github.com/vana-com/vana-dlp-chatgpt.git && cd vana-dlp-chatgpt"

            process_notification "Создаем .env файл (Creating .env file)..."
            run_commands "cp .env.example .env"

            process_notification "Устанавливаем зависимости и CLI (Installing dependencies and CLI)..."
            run_commands "(cd $HOME/vana-dlp-chatgpt && poetry install) && pip install vana"

            echo ""
            show_green "--- НОДА УСТАНОВЛЕНА. NODE INSTALLED ---"
            echo ""
            ;;
        3)
            # WALLETS
            while true; do
                show_orange "Выберите (Choose):"
                echo "1. Создать (Create)"
                echo "2. Восстановить (Restore)"
                echo "3. Выход (Exit)"
                echo ""

                read -p "Введите номер опции (Enter option number): " option

                case $option in
                1)
                    # Create new wallets
                    process_notification "Создаем кошелеки (Creating wallets)..."
                    echo ""
                    show_orange "Придумайте пароль и запишите. Сохраните две мнемоник-фразы — Coldkey и Hotkey"
                    show_blue "-----------------------------------------------------------------------------"
                    show_orange "Come up with a password and write it down. Save two mnemonic phrases — Coldkey and Hotkey"
                    echo ""

                    show_green "Нажмите Enter, чтобы продолжить. Press Enter to proceed"
                    read

                    vanacli wallet create --wallet.name default --wallet.hotkey default

                    show_green "Нажмите Enter, чтобы продолжить. Press Enter to proceed"
                    read

                    process_notification "Экспортируем приватные ключи (Export private keys)..."
                    echo ""
                    show_blue "COLDKEY"
                    echo ""
                    vanacli wallet export_private_key
                    show_green "Нажмите Enter, чтобы продолжить. Press Enter to proceed"
                    read
                    show_blue "HOTKEY"
                    vanacli wallet export_private_key
                    echo ""
                    show_green "Нажмите Enter, чтобы продолжить. Press Enter to proceed"
                    read

                    # Generating keys
                    process_notification "Генерация ключей (Generating keys)..."
                    cd $HOME/vana-dlp-chatgpt/ && source $HOME/.bashrc && ./keygen.sh
                    ;;
                2)
                    # Restore Wallets
                    process_notification "Восстанавливаем кошельки (Restore wallets)..."
                    echo ""
                    read -p "Введите COLD private key: " COLD_PRIVATE_KEY
                    read -p "Введите HOT private key: " HOT_PRIVATE_KEY
                    vanacli w regen_coldkey --seed $COLD_PRIVATE_KEY
                    vanacli w regen_coldkey --seed $HOT_PRIVATE_KEY
                    echo ""
                    show_orange "-------------------------------------------------------------"
                    show_green "Теперь поместите файлы восстановления в папку vana-dlp-chatgpt"
                    show_green "Now place the recovery files in the vana-dlp-chatgpt folder."
                    show_orange "-------------------------------------------------------------"
                    ;;
                3)
                    process_notification "Отмена (Cancel)"
                    break
                    ;;
                *)
                    incorrect_option
                    ;;
                esac
            done
            ;;
        4)
            #  DEPLOY TO MOKSHA
            process_notification "Начинаем деплой (Starting deploy)..."
            echo ""
            sleep 1

            process_notification "Останавливаем ноду (Stopping Node)..."
            if sudo systemctl stop vana.service; then
                sleep 1
                echo ""
                show_green "Успешно (Success)"
                echo ""
            else
                sleep 1
                echo ""
                show_blue "Не запущена (not started)"
                echo ""
            fi

            process_notification "Удаляем папку (Deletting Dir)..."
            run_commands "cd $HOME && rm -rvf vana-dlp-smart-contracts"

            process_notification "Создаем папку (Creating Dir)..."
            run_commands "git clone https://github.com/Josephtran102/vana-dlp-smart-contracts && cd vana-dlp-smart-contracts"

            process_notification "Устанавливаем yarn (Installing Yarn)..."
            run_commands "npm install -g yarn && yarn install && cp .env.example .env"

            # Enter data
            process_notification "Обновляем .env (Updating .env)..."
            echo ""
            read -p "Введите (enter) private coldkey: " PRIVCOLDKEY
            read -p "Введите (enter) coldkey address: " ADDRESSCOLDKEY
            read -p "Введите (enter) DLP name: " DLPNAME
            read -p "Введите (enter) DLP Token Name: " DLPTOKENNAME
            read -p "Введите (enter) DLP Token Symbol: " DLPTOKENSYMBOL

            # Rewrite .env
            if sed -i "s/^DEPLOYER_PRIVATE_KEY=.*/DEPLOYER_PRIVATE_KEY=$PRIVCOLDKEY/" .env && \
                sed -i "s/^OWNER_ADDRESS=.*/OWNER_ADDRESS=$ADDRESSCOLDKEY/" .env && \
                sed -i "s/^DLP_NAME=.*/DLP_NAME=$DLPNAME/" .env && \
                sed -i "s/^DLP_TOKEN_NAME=.*/DLP_TOKEN_NAME=$DLPTOKENNAME/" .env && \
                sed -i "s/^DLP_TOKEN_SYMBOL=.*/DLP_TOKEN_SYMBOL=$DLPTOKENSYMBOL/" .env
            then
                sleep 1
                echo ""
                show_green "Файл .env обновлён. Успешно (Success)"
                echo ""
            else
                sleep 1
                echo ""
                show_red "Файл .env обновлён. Ошибка (Fail)"
                echo ""
            fi

            process_notification "Деплоим контракт (Deploying contract)..."
            run_commands "npx hardhat deploy --network moksha --tags DLPDeploy"
            echo ""
            show_blue "СОХРАНИТЕ (SAVE) DataLiquidityPoolToken и DataLiquidityPool"
            echo ""
            ;;
        5)
            #  VALIDATOR INSTALLATION
            PUBLIC_KEY=$(cat /root/vana-dlp-chatgpt/public_key_base64.asc)
            show_orange "public_key_base64 = $PUBLIC_KEY"
            echo ""
            show_blue "СОХРАНИТЕ В НАДЕЖНОМ МЕСТЕ. STORE IN A SAFE PLACE"
            echo ""
            show_green "Нажмите Enter, чтобы продолжить. Press Enter to proceed"
            read

            process_notification "Редактируем .env (Editing .env)..."
            echo ""
            ENV_FILE="$HOME/vana-dlp-chatgpt/.env"

            read -p "Введите (Enter) OpenAI API Key: " OPENAI_API_KEY
            read -p "Введите (Enter) DATA LIQUIDITY POOL ADDRESS: " DATA_LIQUIDITY_POOL
            read -p "Введите (Enter) DATA_LIQUIDITY POOL TOKEN ADDRESS: " DATA_LIQUIDITY_POOL_TOKEN
            read -p "Введите (Enter) Public Key (base64): " PUBLIC_KEY

            if cat <<EOF > "$ENV_FILE"
# The network to use, currently Vana Moksha testnet
OD_CHAIN_NETWORK=moksha
OD_CHAIN_NETWORK_ENDPOINT=https://rpc.moksha.vana.org

# Optional: OpenAI API key for additional data quality check
OPENAI_API_KEY=$OPENAI_API_KEY

# Optional: Your own DLP smart contract address once deployed to the network, useful for local testing
DLP_MOKSHA_CONTRACT=$DATA_LIQUIDITY_POOL

# Optional: Your own DLP token contract address once deployed to the network, useful for local testing
DLP_TOKEN_MOKSHA_CONTRACT=$DATA_LIQUIDITY_POOL_TOKEN

# The private key for the DLP, follow "Generate validator encryption keys" section in the README
PRIVATE_FILE_ENCRYPTION_PUBLIC_KEY_BASE64=$PUBLIC_KEY
EOF
            then
                sleep 1
                echo ""
                show_green "Успешно (Success)"
                echo ""
            else
                sleep 1
                echo ""
                show_red "Ошибка (Fail)"
                echo ""
            fi

            while true; do
                show_orange "Выберете (Сhoose):"
                echo "1. Создать (Create) Validator"
                echo "2. Восстановить (Restore) Validator"
                echo ""

                read -p "Введите номер опции (Enter option number): " option

                case $option in
                    1)
                        echo ""
                        show_blue "Отправьте 10 своих токенов на COLD И HOT кошельки"
                        echo ""
                        show_blue "Send 10 yours tokens to COLD and HOT wallets"
                        echo ""
                        show_green "Нажмите Enter, чтобы продолжить. Press Enter to proceed"
                        read

                        process_notification "Регистрируем валидатора (Validator registration)..."
                        echo ""
                        cd $HOME/vana-dlp-chatgpt/
                        source $HOME/.bashrc
                        run_commands "./vanacli dlp register_validator --stake_amount 10"
                        echo ""

                        process_notification "Подтверждаем валидатора (Approving Validator)..."
                        echo ""
                        read -p "Введите (Enter) HOT KEY ADDRESS: " HOTKEY_ADDRESS
                        cd $HOME/vana-dlp-chatgpt/
                        source $HOME/.bashrc
                        run_commands "./vanacli dlp approve_validator --validator_address=$HOTKEY_ADDRESS"
                        echo ""
                        break
                        ;;
                    2)
                        break
                        ;;
                    *)
                        incorrect_option
                        ;;
                esac
            done

            process_notification "Создаем сервис (Creating Service)..."
            cd $HOME
            POETRY_PATH=$(which poetry)
            if sudo tee /etc/systemd/system/vana.service << EOF
[Unit]
Description=Vana Validator Service
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/root/vana-dlp-chatgpt
ExecStart=$POETRY_PATH run python -m chatgpt.nodes.validator
Restart=on-failure
RestartSec=10
Environment=PATH=/root/.local/bin:/usr/local/bin:/usr/bin:/bin:/root/vana-dlp-chatgpt/myenv/bin
Environment=PYTHONPATH=/root/vana-dlp-chatgpt

[Install]
WantedBy=multi-user.target
EOF
            then
                sleep 1
                echo ""
                show_green "Успешно (Success)"
                echo ""
            else
                sleep 1
                echo ""
                show_red "Ошибка (Fail)"
                echo ""
            fi

            process_notification "Запускаем сервис (Starting Service)..."
            run_commands "sudo systemctl daemon-reload && sudo systemctl enable vana.service && sudo systemctl start vana.service"

            SERVICE_STATUS=$(sudo systemctl is-active vana.service)
            if [[ "$SERVICE_STATUS" == "active" ]]; then
                echo ""
                show_green "НОДА АКТИВНА И РАБОТАЕТ. NODE IS ACTIVE AND OPERATING"
                echo ""
            else
                echo ""
                show_red "НЕ УДАЛОСЬ ЗАПУСТИТЬ НОДУ. COULDN'T START THE NODE"
                echo ""
            fi
            ;;
        6)
            # Operating
            echo ""
            while true; do
                show_orange "Выберите (Choose):"
                echo "1. Запустить (Start)"
                echo "2. Остановить (Stop)"
                echo "3. Перезапустить (Restart)"
                echo "4. Выход (Exit)"
                echo ""

                read -p "Введите номер опции (Enter option number): " option

                case $option in
                    1)
                        process_notification "Запускаем (Starting) vana.service..."
                        run_commands "sudo systemctl start vana.service"
                        break
                        ;;
                    2)
                        process_notification "Останавливаем (Stopping) vana.service..."
                        run_commands "sudo systemctl stop vana.service"
                        break
                        ;;
                    3)
                        process_notification "Перезапускаем (Restaring) vana.service..."
                        run_commands "sudo systemctl restart vana.service"
                        break
                        ;;
                    4)
                        show_orange "Отмена (Сancel)"
                        echo ""
                        break
                        ;;
                    *)
                        incorrect_option
                        ;;
                esac
            done
            ;;
        7)
            # Check logs
            process_notification "Запускаем логи (Starting logs)"
            sudo journalctl -u vana.service -f
            ;;
        8)
            #Restore
            echo ""
            show_orange "--- TBA. ЗАРЕЗИРВИРОВАНО ---"
            echo ""
            ;;
        9)
            # Update
            echo ""
            show_orange "--- TBA. ЗАРЕЗИРВИРОВАНО ---"
            echo ""
            ;;
        10)
            # Deleting node
            process_notification "Удаляем (Deleting) node..."
            echo ""
            show_red "_____________ !!!WARNING!!! ________________"
            echo ""
            show_orange "УБЕДИТЕСЬ ЧТО ВЫ СОХРАНИЛИ ДАННЫЕ ДЛЯ ВОССТАНОВЛЕНИЯ"
            echo ""
            show_orange "MAKE SURE YOU HAVE SAVED THE RECOVERY DATA"
            echo ""
            show_red "_____________ !!!WARNING!!! ________________"
            echo ""

            while true; do
                read -p "Удалить ноду? Delete node? (yes/no): " option

                case "$option" in
                    yes|y|Y|Yes|YES)
                        process_notification "Удаление (Deleting)..."
                        sudo systemctl stop vana.service
                        sudo systemctl disable vana.service
                        sudo systemctl daemon-reload
                        rm -rvf $HOME/.vana
                        rm -rvf $HOME/vana-dlp-chatgpt
                        rm -rvf $HOME/vana-dlp-smart-contracts
                        show_green "--- НОДА УДАЛЕНА. NODE DELETED. ---"
                        break
                        ;;
                    no|n|N|No|NO)
                        process_notification "Отмена (Cancel)"
                        echo ""
                        break
                        ;;
                    *)
                        incorrect_option
                        ;;
                esac
            done
            ;;
        11)
            # Stop script and exit
            exit_script
            ;;
        *)
            # incorrect options handling
            incorrect_option
            ;;
    esac
done
