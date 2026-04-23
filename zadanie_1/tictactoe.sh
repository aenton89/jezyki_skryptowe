#!/bin/bash

# set -x

SAVE_FILE="save.txt"
board=(" " " " " "
	" " " " " "
	" " " " " ")
is_playing=true
current_player="X"
against_computer=false



### UI RELATED
print_guide(){
	echo "press s to save the game, l to load the game, q to quit, or r to reset the game"
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
	[ "$against_computer" = true ] && echo "playing against: the computer" || echo "playing against: another player"
	echo "current player: $current_player"
	echo
}

### INPUT RELATED
handle_input(){
	read -n 1 -s input
	
	case $input in
		s) save_game ;;
		l) load_game ;;
		q) is_playing=false ;;
		r) reset_game ;;
		[1-9]) player_move $input ;;
	esac
}

ask_yes_no() {
    local question=$1
    local answer

    while true; do
        echo "$question (y/n)"
        read -n 1 -s answer

        case "$answer" in
            y|Y) return 0 ;;
            n|N) return 1 ;;
        esac
    done
}

### GAME STATE RELATED
save_game(){
	saved=("${board[@]}")
	for i in {0..8}; do
		[ "${saved[$i]}" == " " ] && saved[$i]="1"
	done
	echo "${saved[@]}" > $SAVE_FILE
	echo "$current_player" >> $SAVE_FILE
	echo "$against_computer" >> $SAVE_FILE
}

load_game(){
	if [ -f $SAVE_FILE ]; then
		read -a board < $SAVE_FILE
		current_player=$(tail -n 2 $SAVE_FILE | head -n 1)
		against_computer=$(tail -n 1 $SAVE_FILE)

		for i in {0..8}; do
			[ "${board[$i]}" == "1" ] && board[$i]=" "
		done
	fi
}

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

# just a randomly selected move
computer_move(){
	empty_positions=()
	for i in {0..8}; do
		[ "${board[$i]}" == " " ] && empty_positions+=($i)
	done

	if [ ${#empty_positions[@]} -gt 0 ]; then
		random_index=$(( RANDOM % ${#empty_positions[@]} ))
		board[${empty_positions[$random_index]}]=$current_player
	fi

	switch_player
}

switch_player(){
	[ "$current_player" == "X" ] && current_player="O" || current_player="X"
}



# MAIN + GAME LOOP
if ask_yes_no "load previous game?"; then
    load_game
else
    if ask_yes_no "play against the computer?"; then
        against_computer=true
    fi
fi

while $is_playing; do
	clear

	print_guide
	print_info
	print_board

	if $against_computer  && [ "$current_player" == "O" ]; then
		computer_move
	else
		handle_input
	fi

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