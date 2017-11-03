#include <iostream>

using namespace std;
int set_minimum_distance(const int, const int*, const bool*);
void dijkstra(const int, const int*, const int);

int main()
{
    try {

        const int verticies = 6;
        /*
            A(ASCII 65) = 0
            B(ASCII 66) = 1
            C(ASCII 67) = 2
            D(ASCII 68) = 3
            E(ASCII 69) = 4
            F(ASCII 70) = 5
        */

        //Matrix Representation of Graph
        int* matrix_graph = new int[verticies*verticies] {
            0,3,5,9,0,0,
            3,0,3,4,7,0,
            5,3,0,2,6,0,
            9,4,2,0,2,2,
            0,7,6,2,0,5,
            0,0,0,2,5,0
        };
        dijkstra(verticies, matrix_graph, 0);
        delete [] matrix_graph;
    } catch (...) {
        cout << "an error has occurred in the main function. \n\n";
        return -1;
    }

    return 0;
}

//Determine from the remaining vertices which has the smallest weight
int set_minimum_distance(const int verticies, const int* distance, const bool* found_path)
{
    int min_value = INT_MAX;
    int min_index = 0;

    for (int i = 0; i < verticies; ++i) {
        if (*(found_path+i) == false && *(distance+i) <= min_value) {
            min_value = *(distance + i);
            min_index = i;
        }
    }
    return min_index;
}

void dijkstra(const int verticies, const int* graph, const int start)
{
    int* distance = new int[verticies];
    bool* found_shortest_path = new bool[verticies];

    //Initilize the default values
    for (int i = 0; i < verticies; ++i) {
        *(distance + i) = INT_MAX;
        *(found_shortest_path + i) = false;
    }

    //Starting value path is always 0
    *(distance + start) = 0;

    for (int i = 0; i < verticies; ++i) {
        int checker = set_minimum_distance(verticies, distance, found_shortest_path);
        *(found_shortest_path + checker) = true;

        //If there is a better path, change it to that weight.
        for (int j = 0; j < verticies; j++) {
            if (*(found_shortest_path+j) == false
                && *(graph + (verticies*checker + j)) != 0
                && *(distance + checker) != INT_MAX
                && *(distance+checker)+(*(graph + (verticies*checker + j))) < *(distance + j)) {

                *(distance + j) = *(distance + checker) + *(graph + (verticies*checker + j));
            }
        }
    }
    delete [] found_shortest_path;

    for (int i = 0; i < verticies; ++i) {
        cout << "Shortest Path from vertex " << (char)(start+65) << " to "
            << (char)(i+65) << " is: " << *(distance+i) << endl;
    }
    delete [] distance;

}
