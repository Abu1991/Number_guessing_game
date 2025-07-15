#!/bin/bash
PSQL="psql --csv --username=freecodecamp --dbname=number_guess --tuples-only -c"

SECRET=$[ $RANDOM % 1000 + 1 ]

echo -e "\nEnter your username:"
read USERNAME

# get user information
USER=$($PSQL "SELECT username, games_played, best_game FROM users WHERE username = '$USERNAME';")

if [[ -z $USER ]]
then
  INSERT_USER_RESULT=$($PSQL "INSERT INTO "users" (username, games_played, best_game) VALUES('$USERNAME', 0, 0);")
  echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
else
  IFS=',' read USERNAME GAMES_PLAYED BEST_GAME <<< $USER
  echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

echo "Guess the secret number between 1 and 1000:"
read PREDICT

NUMBER_OF_GUESSES=1

# if prediction not equal to secret
while [[ $PREDICT != $SECRET ]]
do
  # if not a number
  if [[ ! $PREDICT =~ ^-?[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
  # if prediction is higher
  elif [[ $PREDICT > $SECRET ]]
  then
    echo "It's lower than that, guess again:"
  # if prediction is lower
  elif [[ $PREDICT < $SECRET ]]
  then
    echo "It's higher than that, guess again:"
  fi

  read PREDICT

  NUMBER_OF_GUESSES=$(( $NUMBER_OF_GUESSES + 1 ))
done

# save game information to the database
if [[ -z $BEST_GAME || $BEST_GAME == 0 || $NUMBER_OF_GUESSES < $BEST_GAME ]]
then
  UPDATE=$($PSQL "UPDATE "users" SET best_game = $NUMBER_OF_GUESSES, games_played = games_played + 1 WHERE username = '$USERNAME'")
else
  UPDATE=$($PSQL "UPDATE "users" SET games_played = games_played + 1 WHERE username = '$USERNAME'")
fi

echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET. Nice job!"
