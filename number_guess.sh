#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo -e "\nEnter your username: "
read USER_NAME

LOOK_FOR_USERNAME=$($PSQL "SELECT * FROM usernames WHERE username = '$USER_NAME'")
echo "$LOOK_FOR_USERNAME" | sed 's/|/ /g' | while read USER GAMES_PLAYED_DATABASE BEST_GAME_GUESSES_DATABASE
do
    GAMES_PLAYED=$(($GAMES_PLAYED_DATABASE))
    BEST_GAME_GUESSES=$(($BEST_GAME_GUESSES_DATABASE))

if [[ -z $LOOK_FOR_USERNAME ]]
then
  echo -e "\nWelcome, $USER_NAME! It looks like this is your first time here."
  INSERT_USERNAME=$($PSQL "INSERT INTO usernames(username) VALUES('$USER_NAME')")
else
  echo "$LOOK_FOR_USERNAME" | sed 's/|/ /g' | while read USER GAMES_PLAYED_DATABASE BEST_GAME_GUESSES_DATABASE
  do
    GAMES_PLAYED=$(($GAMES_PLAYED_DATABASE))
    BEST_GAME_GUESSES=$(($BEST_GAME_GUESSES_DATABASE))
    echo "Welcome back, $USER_NAME! You have played $GAMES_PLAYED_DATABASE games, and your best game took $BEST_GAME_GUESSES_DATABASE guesses."
  
  done
fi

echo -e "\nGuess the secret number between 1 and 1000:"
UPDATE_USER_GAMES=$($PSQL "UPDATE usernames SET games_played = $(($GAMES_PLAYED + 1)) WHERE username = '$USER_NAME'")
done

GUESSES=0
NUMBER=$(($RANDOM % 1000 +1))


GUESS() {
  read GUESSED_NUMBER

  if [[ ! $GUESSED_NUMBER =~ ^[0-9]+$ ]]
  then
    echo -e "\nThat is not an integer, guess again:"
    GUESS
  else
    GUESSES=$(($GUESSES + 1))
    if (( GUESSED_NUMBER < NUMBER))
    then
      echo -e "\nIt's higher than that, guess again:"
      GUESS
    elif (( GUESSED_NUMBER > NUMBER))
    then
      echo -e "\nIt's lower than that, guess again:"
      GUESS
    else
      if [[ $BEST_GAME_GUESSES < 1 ]] || [[ $BEST_GAME_GUESSES > $GUESSES ]]
      then
        UPDATE_USER_GAMES=$($PSQL "UPDATE usernames SET best_game_guesses = $GUESSES WHERE username = '$USER_NAME'")
      fi
      echo -e "\nYou guessed it in $GUESSES tries. The secret number was $NUMBER. Nice job!"
    fi

  fi
}

GUESS
