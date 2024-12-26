#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=number_guess --tuples-only -c"



echo "Enter your username:"
read USERNAME

USERNAME_RESULT=$($PSQL "select user_id,username,games_played from users left join games USING(user_id) where username='$USERNAME' " )
# echo $USERNAME_RESULT

if [[ -z $USERNAME_RESULT ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  USER_RESULT=$($PSQL "insert into users(username) values ('$USERNAME')")
else
  # echo $USERNAME_RESULT | read USER_ID  BARUSERNAME BAR GAMES_PLAYED
  read USER_ID BAR USERNAME BAR GAMES_PLAYED <<< "$(echo "$USERNAME_RESULT")"
  BEST_GAME="$($PSQL "select MIN(number_of_guesses) from games join users  using(user_id) where username='$USERNAME'")"
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi


SECRET_NUMBER=$((RANDOM % 1000 + 1))

echo "Guess the secret number between 1 and 1000:"
NOG=0

while [[ $INPUT != $SECRET_NUMBER ]]
do
  ((NOG++))
  read INPUT
  if [[ ! "$INPUT" =~ ^-?[0-9]+$  ]]
  then
    echo "That is not an integer, guess again:"
  elif [[ $INPUT -gt $SECRET_NUMBER ]]
  then 
    echo "It's lower than that, guess again:"
  elif [[ $INPUT -lt $SECRET_NUMBER ]]
  then
    echo "It's higher than that, guess again:"
  fi
done

USER_ID=$($PSQL "select user_id from users where username='$USERNAME' " )
GAME_RESULT=$($PSQL "insert into games(user_id,number_of_guesses) values ($USER_ID,$NOG)")
update_games_played=$($PSQL "update users set games_played=(select count(game_id) from games where users.user_id = games.user_id )")

echo "You guessed it in $NOG tries. The secret number was $SECRET_NUMBER. Nice job!"
