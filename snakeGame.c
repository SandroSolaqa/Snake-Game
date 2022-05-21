/*
 SANDY SOlAQA
 825945946
 SNAKE GAME
 KEN ARNOLD
*/

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <time.h>
#include <conio.h>

#define H 20 // game field height
#define W 20 // game field width
#define KEY1 'a' // key to turn counter-clockwise
#define KEY2 'd' // key to turn clockwise
#define WAITING 0.3 // time between each step

int mainOption = 0; // user selection on the main menu
int score = 0; // game score
char arrow = ' '; // pressed key at each step
int direction = 0; // snake direction, 0 = up, 1 = right, 2 = down, 3 = left
int apple[2] = { 0, 0 }; // apple position at empty area
int oldApple[2] = { 0, 0 }; // the random apple position, might be generated at snake position
int tail[2] = { 0, 0 }; // position of snake tail


// struct to store snake information
typedef struct
{
    // positiotion coordinates of each part
    int position[W*H][2];
    // number of parts
    int size;
} Snake;

// struct to store the game field
typedef struct
{
    // character 2D array of field positions
    char position[H][W];
} Field;

// global field and snake
Field* field;
Snake* snake;

// functions prototypes
void startEngine(); // game engine that handles the main menu
void printMain(); // print the main menu
int getOption(int, int); // get user option from lower boundary int to higher boundary int
char getArrow(); // get user key pressed from one of the two global keys
void turn(int); // turn snake clockwise when int = 1, and counter-clockwise = -1
void forward(); // move snake forward
void printRules(); // print game rules
void initializeSession(); // initialize snake, field, score, and apple
void snakeSession(); // process game session
void printGameField(); // print field using the global field object
int replaceApple(); // place apple at a random place on the game field
int placeAppleEmpty(); // makes sure that the apple lies on an empty place
int checkStatus(); // check if snake ate an apple or ate itself

int main()
{
    // start game
    startEngine();
    return 0;
}

void printMain()
{
    printf("=========================\n");
    printf("Please select an option\n");
    printf("=========================\n");
    printf("0 - play\n");
    printf("1 - rules\n");
    printf("2 - quit\n");
    printf("=========================\n");
    printf("your option: ");
}

int getOption(int lower, int upper)
{
    int option = 0; // user option
    int inputCount = 0; // how many items were scanned from stdin
    inputCount = scanf_s("%d", &option); // ask the user to enter an option, count the number of integers scanned
    // check if there is only one integer scanned
    // the input is in the correct range
    while (inputCount != 1 || option < lower || option > upper)
    {
        printf("invalid input!\n");
        while ((getchar()) != '\n'); // clear the stdin buffer
        printf("try again: ");
        // rescan the user input
        inputCount = scanf_s("%d", &option);
    }
    return option;
}

char getArrow()
{
    char key = ' '; // user preseed key
    clock_t t = clock(); // starting time of calling the function


    // check if pressed key is one of the global arrows or if the elapsed time exceeds the WAITING time
    while ((key != KEY1 && key != KEY2) && ((double)(clock() - t)) / CLOCKS_PER_SEC < WAITING)
    {
        // check if the user pressed a key
        if (_kbhit())
        {
            // get the pressed key
            key = _getch();
        }
    }
    // if the pressed key isn't one of the global keys
    if (key != KEY1 && key != KEY2)
    {
        // reset key to the global arrow
        key = arrow;
    }

    return key;
}

void printRules()
{
    printf("=========================\n");
    printf("Eat apples (*) to increase your score.\n");
    printf("Press 'a' to turn counter-clockwise, and press 'd' to turn clockwise.\n");
    printf("You can circulate through boundaries.\n");
}

void printGameField()
{
    printf("=========================\n");
    printf("Score: %d\n", score);
    printf("=========================\n");
    // loop through rows
    for (int i = 0; i < H + 2; i++)
    {
        // loop through columns
        for (int j = 0; j < W + 2; j++)
        {
            // if i or j in the boundaries
            if (i == 0 || j == 0 || i == H+1 || j == W+1)
            {
                printf("#");
            }
            // if i and j matches the apple position
            else if (i-1 == apple[0] && j-1 == apple[1])
            {
                printf("*");
            }
            // print the character at i,j position of the global field
            else
            {
                printf("%c", field->position[i-1][j-1]);
            }
        }
        // split rows
        printf("\n");
    }
}

void turn(int clockwise)
{
    // circle through the four directions in the specified direction
    direction = (direction + clockwise) % 4;
    // correct negative direction
    if (direction < 0)
    {
        direction += 4;
    }
}

void forward()
{
    // if snake is looking up
    if (direction == 0)
    {
        // move snake head on the y axis to the upper boundary
        // circles through the height axis
        snake->position[snake->size - 1][0] = (snake->position[snake->size - 1][0] - 1) % H;
        // corrects negative position
        if (snake->position[snake->size - 1][0] < 0)
        {
            snake->position[snake->size - 1][0] += H;
        }
    }
    // if snake is looking right
    else if (direction == 1)
    {
        // move snake head on the x axis to the right boundary
        // circles through the width axis
        snake->position[snake->size - 1][1] = (snake->position[snake->size - 1][1] + 1) % W;
    }
    // if snake is looking down
    else if (direction == 2)
    {
        // move snake head on the y axis to the lower boundary
        // circles through the height axis
        snake->position[snake->size - 1][0] = (snake->position[snake->size - 1][0] + 1) % H;
    }
    // else snake is looking left
    else
    {
        // move snake head on the x axis to the left boundary
        // circles through the width axis
        snake->position[snake->size - 1][1] = (snake->position[snake->size - 1][1] - 1) % W;
        // corrects negative position
        if (snake->position[snake->size - 1][1] < 0)
        {
            snake->position[snake->size - 1][1] += W;
        }
    }
}

int placeAppleEmpty()
{
    // check if the field at the apple position is not occupied by the snake
    if (field->position[apple[0]][apple[1]] != 'o')
    {
        return 1;
    }
    // the apple position is occupied by the snake
    else
    {
        // move the apple position in the y-axis by one position
        apple[0] = (apple[0] + 1) % H;
        // if we returned to the original random apple position
        if (oldApple[0] == apple[0] && oldApple[1] == apple[1])
        {
            return 0;
        }
        // else if the new position is empty
        else if (placeAppleEmpty() == 1)
        {
            return 1;
        }

        // move the apple position in the x-axis by one position
        apple[1] = (apple[1] + 1) % W;
        // if we returned to the original random apple position
        if (oldApple[0] == apple[0] && oldApple[1] == apple[1])
        {
            return 0;
        }
        // else if the new position is empty
        else if (placeAppleEmpty() == 1)
        {
            return 1;
        }

        // no place on the field is empty
        return 0;
    }
}

int replaceApple()
{
    // generate random cordinates for the apple
    apple[0] = rand() %  H;
    apple[1] = rand() %  W;
    // store this place
    oldApple[0] = apple[0];
    oldApple[1] = apple[1];
    // make sure the apple lies on an empty position
    if (placeAppleEmpty() == 0)
    {
        return 0;
    }
    else
    {
        return 1;
    }
}

void initializeSession()
{
    score = 0; // zero score
    direction = 0; // initial direction looking up

    field = calloc(1, sizeof(Field)); // allocate memory to the global field pointer
    snake = calloc(1, sizeof(Snake)); // allocate memory to the snake field pointer

    // initialize the snake at center
    snake->position[0][0] = H / 2;
    snake->position[0][1] = W / 2;
    snake->size = 1;

    // initialize all the field as empty
    for (int i = 0; i < H; i++)
    {
        for (int j = 0; j < W; j++)
        {
            field->position[i][j] = ' ';
        }
    }

    // place the snake on the field
    field->position[H / 2][W / 2] = 'o';

    // place apple randomly
    replaceApple(field);
}

int checkStatus() {
    // if snake head lies at the apple position
    if (snake->position[snake->size - 1][0] == apple[0] && snake->position[snake->size - 1][1] == apple[1])
    {
        // increase snake size
        snake->size++;
        // increase score by 10
        score += 10;
        // move each snake part one step forward
        for (int i = (snake->size - 1); i > 0; i--)
        {
            snake->position[i][0] = snake->position[i - 1][0];
            snake->position[i][1] = snake->position[i - 1][1];
        }
        // re-add the snake tail position
        snake->position[0][0] = tail[0];
        snake->position[0][1] = tail[1];
        // re-draw the snake tail
        field->position[tail[0]][tail[1]] = 'o';
        // check if apple couldn't be placed on an empty place
        if (replaceApple() == 0)
        {
            return 0;
        }
    }
    // check if snake head lies on its body
    else if (field->position[snake->position[snake->size - 1][0]][snake->position[snake->size - 1][1]] == 'o')
    {
        return 0;
    }
    return 1;
}

void snakeSession()
{
    // initialize snake, field, score, and apple
    initializeSession();
    // loop forever
    while (1)
    {
        // clear terminal
        system("cls");
        // print field
        printGameField();
        // get user pressed key
        arrow = getArrow();
        // store sneak tail position
        tail[0] = snake->position[0][0];
        tail[1] = snake->position[0][1];
        // erase snake tail from the field
        field->position[snake->position[0][0]][snake->position[0][1]] = ' ';
        // move each snake part one step backward
        for (int i = 0; i < (snake->size - 1); i++)
        {
            snake->position[i][0] = snake->position[i + 1][0];
            snake->position[i][1] = snake->position[i + 1][1];
        }
        // if user pressed a, turn counter-clockwise
        if (arrow == 'a')
        {
            turn(-1);
        }
        // if user pressed d, turn clockwise
        else if (arrow == 'd')
        {
            turn(1);
        }
        // move snake forward in the current direction
        forward();
        arrow = ' ';
        // if snake ate itself or the apple can't be place at an empty place
        if (checkStatus() == 0)
        {
            break;
        }
        // draw the new snake head on field
        field->position[snake->position[snake->size - 1][0]][snake->position[snake->size - 1][1]] = 'o';
    }
    // free allocated memory
    free(field);
    free(snake);
}

void startEngine()
{
    // set random seed
    srand(time(NULL));
    // while the user didn't quit
    while (mainOption != 2)
    {
        printMain();
        // get user input in range [0,2]
        mainOption = getOption(0, 2);
        switch (mainOption)
        {
        case 0:
            snakeSession();
            break;
        case 1:
            printRules();
            break;
        }
    }
}
