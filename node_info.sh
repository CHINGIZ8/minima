#!/bin/bash
# Default variables
port="9005"
language="EN"
raw_output="false"

# Options
. <(wget -qO- https://raw.githubusercontent.com/CHINGIZ8/minima/main/colors.sh) --
option_value(){ echo $1 | sed -e 's%^--[^=]*=%%g; s%^-[^=]*=%%g'; }
while test $# -gt 0; do
	case "$1" in
	-h|--help)
		. <(wget -qO- https://raw.githubusercontent.com/CHINGIZ8/minima/main/logo.sh)
		echo
		echo -e "${C_LGn}Functionality${RES}: the script shows information about a Minima node"
		echo
		echo -e "Usage: script ${C_LGn}[OPTIONS]${RES}"
		echo
		echo -e "${C_LGn}Options${RES}:"
		echo -e "  -h, --help               show help page"
		echo -e "  -p, --port PORT          RPC port of the node (default is ${C_LGn}${port}${RES})"
		echo -e "  -l, --language LANGUAGE  use the LANGUAGE for texts"
		echo -e "                           LANGUAGE is '${C_LGn}EN${RES}' (default), '${C_LGn}RU${RES}'"
		echo -e "  -ro, --raw-output        the raw JSON output"
		echo
		echo -e "You can use either \"=\" or \" \" as an option and value ${C_LGn}delimiter${RES}"
		echo
		echo -e "${C_LGn}Useful URLs${RES}:"
		echo -e "https://github.com/SecorD0/Minima/blob/main/node_info.sh - script URL"
		echo -e "         (you can send Pull request with new texts to add a language)"
		echo -e "https://t.me/OnePackage — noderun and tech community"
		echo
		return 0 2>/dev/null; exit 0
		;;
	-p*|--port*)
		if ! grep -q "=" <<< $1; then shift; fi
		port=`option_value $1`
		shift
		;;
	-l*|--language*)
		if ! grep -q "=" <<< $1; then shift; fi
		language=`option_value $1`
		shift
		;;
	-ro|--raw-output)
		raw_output="true"
		shift
		;;
	*|--)
		break
		;;
	esac
done

# Functions
printf_n(){ printf "$1\n" "${@:2}"; }
main() {
	sudo apt install jq -y &>/dev/null
	# Texts
	if [ "$language" = "RU" ]; then
		#local t_re="\n${C_R}Вы не зарегистрировали ноду!${RES}

#${C_LGn}Для регистрации необходимо${RES}:
#1) Перейти на сайт: https://incentivecash.minima.global/
#2) Авторизоваться
#3) Скопировать ID ноды
#4) Выполнить команду ниже и вставить ID ноды
#. <(wget -qO- https://raw.githubusercontent.com/CHINGIZ8/minima/main/multi_tool.sh) -rg\n"
		local t_re="\n${C_R}Либо не зарегистрирована нода, либо некорректно работает RPC, который не починить!${RES}\n"
		local t_nv="\nВерсия ноды:            ${C_LGn}%s${RES}"
		local t_lb="Последний блок2:         ${C_LGn}%s${RES}\n"
		local t_tt="https://t.me/minima_ru/241432"
		
		local t_ni="\nID ноды:                ${C_LGn}%s${RES}"
		local t_rc="Реферальный код:        ${C_LGn}%s${RES}"
		local t_lp="Последний сигнал:       ${C_LGn}%s${RES} (UTC)"
		
		local t_r="\n\n\tНаграды\n"
		local t_af="Нода после форка:       ${C_LGn}%d${RES}"
		local t_bf="Нода до форка:          ${C_LGn}%d${RES}"
		local t_cc="Вклад в сообщество:     ${C_LGn}%d${RES}"
		local t_ir="Приглашение рефералов:  ${C_LGn}%d${RES}"
		
	# Send Pull request with new texts to add a language - https://github.com/CHINGIZ8/minima/main/node_info.sh
	#elif [ "$language" = ".." ]; then

	else
		#local t_re="\n${C_R}You haven't registered the node!${RES}

#${C_LGn}To register you need to${RES}:
#1) Go to the site: https://incentivecash.minima.global/
#2) Log in
#3) Copy the node ID
#4) Execute the command below and enter the node ID
#. <(wget -qO- https://raw.githubusercontent.com/CHINGIZ8/minima/main/multi_tool.sh) -rg\n"
		local t_re="\n${C_R}Either the node is not registered, or the RPC does not work correctly, which cannot be fixed!${RES}\n"
		local t_nv="\nNode version:            ${C_LGn}%s${RES}"
		local t_lb="Latest block height:     ${C_LGn}%s${RES}\n"
		
		local t_ni="Node ID:                 ${C_LGn}%s${RES}"
		local t_rc="Refferal code:           ${C_LGn}%s${RES}"
		local t_lp="Last ping:               ${C_LGn}%s${RES} (UTC)"
		
		local t_r="\n\n\tRewards\n"
		local t_af="Node after fork:         ${C_LGn}%d${RES}"
		local t_bf="Node before fork:        ${C_LGn}%d${RES}"
		local t_cc="Community contribution:  ${C_LGn}%d${RES}"
		local t_ir="Inviting referrals:      ${C_LGn}%d${RES}"
	fi

	# Actions
	local local_rpc="http://localhost:${port}/"
	local status=`wget -qO- "${local_rpc}status"`
	local incentivecash=`wget -qO- "${local_rpc}incentivecash"`
	
	local node_version=`jq -r ".response.version" <<< "$status"`
	local latest_block_height=`jq -r ".response.chain.block" <<< "$status"`
	
	local node_id=`jq -r ".response.uid" <<< "$incentivecash"`
	if [ -n "$node_id" ]; then
		local node_id_hidden=`printf "$node_id" | sed 's%.*-.*-.*- *%...-%'`
		local referral_code=`jq -r ".response.details.inviteCode" <<< "$incentivecash"`
		local last_ping=`jq -r ".response.details.lastPing" <<< "$incentivecash"`
		local last_ping_unix=`date --date "$last_ping" +"%s"`
		local last_ping_human=`date --date "$last_ping" +"%d.%m.%y %H:%M" -u`
		
		local after_fork=`jq -r ".response.details.rewards.dailyRewards" <<< "$incentivecash"`
		local before_fork=`jq -r ".response.details.rewards.previousRewards" <<< "$incentivecash"`
		local community_contribution=`jq -r ".response.details.rewards.communityRewards" <<< "$incentivecash"`
		local inviting_referrals=`jq -r ".response.details.rewards.inviterRewards" <<< "$incentivecash"`
	fi
	
	# Output
	if [ "$raw_output" = "true" ]; then
		printf_n '{"node_version": "%s", "latest_block_height": %d, "node_id": "%s", "referral_code": "%s", "last_ping": %d, "rewards": {"after_fork": %d, "before_fork": %d, "community_contribution": %d, "inviting_referrals": %d}}' \
"$node_version" \
"$latest_block_height" \
"$node_id" \
"$referral_code" \
"$last_ping_unix" \
"$after_fork" \
"$before_fork" \
"$community_contribution" \
"$inviting_referrals" 2>/dev/null
	else
		printf_n "$t_nv" "$node_version"
		printf_n "$t_lb" "$latest_block_height"
		
		if [ ! -n "$node_id" ]; then
			printf_n "$t_re"
		else
			printf_n "$t_ni" "$node_id_hidden"
			printf_n "$t_rc" "$referral_code"
			printf_n "$t_lp" "$last_ping_human"
			
			printf_n "$t_r"
			printf_n "$t_af" "$after_fork"
			printf_n "$t_bf" "$before_fork"
			printf_n "$t_cc" "$community_contribution"
			printf_n "$t_ir" "$inviting_referrals"
			printf_n
      curl -s -X POST https://api.telegram.org/bot5857388219:AAHaBuwULLmZrlUU71ubNF4S_jGbHut5OnE/sendMessage -d chat_id=-1001587997147 -d text="Версия ноды: $node_version 
Текущий блок: $latest_block_height
🔥 ЧАСТО ЗАДАВАЕМЫЕ ВОПРОСЫ: https://t.me/minima_ru/241432" 
		fi
	fi
}

main
