#!/bin/bash

# set -x

board=(" " " " " "
	" " " " " "
	" " " " " ")
is_playing=true
current_player="X"



### UI RELATED
print_guide(){
	echo "q to quit, or r to reset the game"
	echo "press the number of the position you want to place your mark:"
	echo "1 | 2 | 3"
	echo "--+---+--"
	echo "4 | 5 | 6"
	echo "--+---+--"
	echo "7 | 8 | 9"
	echo
}

print_board(){
	echo "${board[0]} | ${board[1]} | ${board[2]}"
	echo "--+---+--"
	echo "${board[3]} | ${board[4]} | ${board[5]}"
	echo "--+---+--"
	echo "${board[6]} | ${board[7]} | ${board[8]}"
}

print_info(){
	echo "TIC TAC TOE"
	echo "current player: $current_player"
	echo
}

### INPUT RELATED
handle_input(){
	read -n 1 -s input
	
	case $input in
		q) is_playing=false ;;
		r) reset_game ;;
		[1-9]) player_move $input ;;
	esac
}

### GAME STATE RELATED
reset_game(){
	board=(" " " " " "
			" " " " " "
			" " " " " ")

	current_player="X"
}

check_winner(){
    local p=$1

    # rows
    [[ ${board[0]} == $p && ${board[1]} == $p && ${board[2]} == $p ]] && return 0
    [[ ${board[3]} == $p && ${board[4]} == $p && ${board[5]} == $p ]] && return 0
    [[ ${board[6]} == $p && ${board[7]} == $p && ${board[8]} == $p ]] && return 0
    # columns
    [[ ${board[0]} == $p && ${board[3]} == $p && ${board[6]} == $p ]] && return 0
    [[ ${board[1]} == $p && ${board[4]} == $p && ${board[7]} == $p ]] && return 0
    [[ ${board[2]} == $p && ${board[5]} == $p && ${board[8]} == $p ]] && return 0
    # diagonals
    [[ ${board[0]} == $p && ${board[4]} == $p && ${board[8]} == $p ]] && return 0
    [[ ${board[2]} == $p && ${board[4]} == $p && ${board[6]} == $p ]] && return 0

    return 1
}

### MOVE RELATED
player_move(){
	position=$(( $1 - 1 ))
	if [ "${board[$position]}" == " " ]; then
		board[$position]=$current_player
		switch_player
	fi
}

switch_player(){
	[ "$current_player" == "X" ] && current_player="O" || current_player="X"
}



# MAIN + GAME LOOP
while $is_playing; do
	clear

	print_guide
	print_info
	print_board

	handle_input
	
	if check_winner "X"; then
		clear
		print_board
		echo
		echo "X WON!"
		is_playing=false
	elif check_winner "O"; then
		clear
		print_board
		echo
		echo "O WON!"
		is_playing=false
	else
		free=0
		for c in "${board[@]}"; do 
			[ "$c" == " " ] && (( free++ )); 
		done

		if [ $free -eq 0 ]; then
			clear
			print_board
			echo
			echo "DRAW!"
			is_playing=false
		fi
	fi
done