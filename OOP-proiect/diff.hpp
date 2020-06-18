//  Created by Denis Mitã on 17/05/16.
//  Copyright © 2016 Denis Mitã. All rights reserved.
//
//  O(ND) Algorithm for text diffing
//  Paper source : http://www.xmailserver.org/diff2.pdf

#ifndef DIFF_HPP
#define DIFF_HPP

#include <map>
#include <string>
#include <vector>

// For not confusing the values
enum diff_type {
    EQUAL,
    INSERT,
    ERASE
};

// Main diffing class
class Diff {
  private:
    // The 2 texts
    std::string textA, textB;
    // Contains the diffs between texts, in case we need it more than once
    std::vector<std::pair<diff_type, std::string> > diffs;
    // Increments the 2 indices while the positions have equal values
    void forward_advance(int &i, int &j, std::string &A, std::string &B) {
        while (i + 1 != A.length() && j + 1 != B.length() && A[i + 1] == B[j + 1]) {
            i += 1;
            j += 1;
        }
    }
    // Decrements the 2 indices while the positions have equal values
    void backward_advance(int &i, int &j, std::string &A, std::string &B) {
        while (i != 0 && j != 0 && A[i] == B[j]) {
            i -= 1;
            j -= 1;
        }
    }
    // Checks wether a cell is in range of the matrix dynamic
    bool is_in_range(std::pair<int, int> cell) {
        return (cell.first >= 0 && cell.first <= textA.length() && cell.second >= 0 && cell.second <= textB.length());
    }
    // Returns the coordinates describing the snake
    std::vector<std::pair<int, int> > get_points(std::pair<int, int> a, std::pair<int, int> b, std::map<std::pair<int, int>, std::pair<int, int>> &father) {
        std::vector<std::pair<int, int> > points;
        // Compute the prefix points of the snake
        while (is_in_range(a)) {
            points.push_back(a);
            auto parent = father[a];
            // We were skipping the equals but now me must take them all
            while (textA[a.first - 1] == textB[a.second - 1] && a.first - 1 >= parent.first && a.second - 1 >= parent.second) {
                a.first -= 1;
                a.second -= 1;
                if (is_in_range(a)) {
                    points.push_back(a);
                } else {
                    break;
                }
            }
            a = parent;
        }
        // We need to reverse them as they are in the opposite order
        std::reverse(points.begin(), points.end());
        // Compute the suffix points of the snake (these are inserted in the right order)
        while (is_in_range({b.first, b.second})) {
            points.push_back(b);
            auto parent = father[b];
            // Same thing as in previous while
            while (textA[b.first] == textB[b.second] && b.first + 1 <= parent.first && b.second + 1 <= parent.second) {
                b.first += 1;
                b.second += 1;
                if (is_in_range(b)) {
                    points.push_back(b);
                } else {
                    break;
                }
            }
            b = parent;
        }
        // We were working with 1-indexed cells, so we have to decrement them
        for (auto &it : points) {
            it.first -= 1;
            it.second -= 1;
        }
        return points;
    }
    // Returns the snake path in the dynamic matrix described as a succes
    std::vector<std::pair<int, int> > compute_snake(std::string A, std::string B) {
        // We have to index the dynamic from 1
        A = " " + A;
        B = " " + B;
        // Indices for comparing texts
        int begin_i = 0;
        int begin_j = 0;
        int end_i = A.length() - 1;
        int end_j = B.length() - 1;
        
        // Maximum editing distance
        int maxD = (2 + A.length() + B.length());
        
        // Remember positions in the "snakes"
        std::vector<std::map<int, std::pair<int, int> > > distance_begin(maxD);
        std::vector<std::map<int, std::pair<int, int> > > distance_end(maxD);
        // We need this for remembering the track of the cells
        std::map<std::pair<int, int>, std::pair<int, int> > father;
        // We use these to mark whether we reached the cell on the other corner
        std::map<std::pair<int, int>, bool> reachA;
        std::map<std::pair<int, int>, bool> reachB;
        
        forward_advance(begin_i, begin_j, A, B);
        distance_begin[0][0] = {begin_i, begin_j};
        father[{begin_i, begin_j}] = {-1, -1};
        reachA[{begin_i, begin_j}] = true;
        
        // In this case the taexts are identical
        if (begin_i == A.length() - 1 && begin_j == B.length() - 1) {
            return get_points({begin_i, begin_j}, {end_i + 1, end_j + 1}, father);
        }
        
        distance_end[0][(int)B.length() - (int)A.length()] = {end_i, end_j};
        father[{end_i, end_j}] = {A.length(), B.length()};
        reachB[{end_i, end_j}] = true;
        
        // Iterate through the diffing distance
        for (int d = 1; d <= maxD; d += 1) {
            // In all of the if conditions that are followed by returns it means that the 2 snakes have met
            // Iterate throguh the best for each diagonal starting from top-left
            for (auto &it : distance_begin[d - 1]) {
                // Advance and update by making another step
                int diagonal_decay = it.first;
                begin_i = it.second.first;
                begin_j = it.second.second;
                if (begin_i + 1 < A.length()) {
                    int new_decay = diagonal_decay - 1;
                    int new_i = begin_i + 1;
                    int new_j = begin_j;
                    if (reachB[{new_i, new_j}]) {
                        return get_points(it.second, {new_i, new_j}, father);
                    }
                    forward_advance(new_i, new_j, A, B);
                    if (new_decay != -d && new_decay != d) {
                        reachA[distance_begin[d + 1][new_decay]] = false;
                        auto cell = distance_begin[d + 1][new_decay];
                        if (cell.first + cell.second < new_i + new_j) {
                            distance_begin[d + 1][new_decay] = {new_i, new_j};
                            father[{new_i, new_j}] = {begin_i, begin_j};
                        }
                    } else {
                        distance_begin[d + 1][new_decay] = {new_i, new_j};
                        father[{new_i, new_j}] = {begin_i, begin_j};
                    }
                    reachA[distance_begin[d + 1][new_decay]] = true;
                }
                
                if (begin_j + 1 < B.length()) {
                    int new_decay = diagonal_decay + 1;
                    int new_i = begin_i;
                    int new_j = begin_j + 1;
                    if (reachB[{new_i, new_j}]) {
                        return get_points(it.second, {new_i, new_j}, father);
                    }
                    forward_advance(new_i, new_j, A, B);
                    if (new_decay != -d && new_decay != d) {
                        reachA[distance_begin[d + 1][new_decay]] = false;
                        auto cell = distance_begin[d + 1][new_decay];
                        if (cell.first + cell.second < new_i + new_j) {
                            distance_begin[d + 1][new_decay] = {new_i, new_j};
                            father[{new_i, new_j}] = {begin_i, begin_j};
                        }
                    } else {
                        distance_begin[d + 1][new_decay] = {new_i, new_j};
                        father[{new_i, new_j}] = {begin_i, begin_j};
                    }
                    reachA[distance_begin[d + 1][new_decay]] = true;
                }
            }
            // Same as previous for but starting from bottom-right
            for (auto &it : distance_end[d - 1]) {
                // Same as previous for
                int diagonal_decay = it.first;
                end_i = it.second.first;
                end_j = it.second.second;
                backward_advance(end_i, end_j, A, B);
                father[{end_i, end_j}] = father[{it.second.first, it.second.second}];
                
                if (end_i - 1 >= 0) {
                    int new_decay = diagonal_decay + 1;
                    int new_i = end_i - 1;
                    int new_j = end_j;
                    if (reachA[{new_i, new_j}]) {
                        return get_points({new_i, new_j}, {end_i, end_j}, father);
                    }
                    if (new_decay != -d && new_decay != d) {
                        reachB[distance_end[d + 1][new_decay]] = false;
                        auto cell = distance_end[d + 1][new_decay];
                        if (cell.first + cell.second < new_i + new_j) {
                            distance_end[d + 1][new_decay] = {new_i, new_j};
                            father[{new_i, new_j}] = {end_i, end_j};
                        }
                    } else {
                        distance_end[d + 1][new_decay] = {new_i, new_j};
                        father[{new_i, new_j}] = {end_i, end_j};
                    }
                    reachB[distance_end[d + 1][new_decay]] = true;
                }
                
                if (end_j - 1 >= 0) {
                    int new_decay = diagonal_decay - 1;
                    int new_i = end_i;
                    int new_j = end_j - 1;
                    if (reachA[{new_i, new_j}]) {
                        return get_points({new_i, new_j}, {end_i, end_j}, father);
                    }
                    if (new_decay != -d && new_decay != d) {
                        reachB[distance_end[d + 1][new_decay]] = false;
                        auto cell = distance_end[d + 1][new_decay];
                        if (cell.first + cell.second < new_i + new_j) {
                            distance_end[d + 1][new_decay] = {new_i, new_j};
                            father[{new_i, new_j}] = {end_i, end_j};
                        }
                    } else {
                        distance_end[d + 1][new_decay] = {new_i, new_j};
                        father[{new_i, new_j}] = {end_i, end_j};
                    }
                    reachB[distance_end[d + 1][new_decay]] = true;
                    
                }
            }
        }
        return {{0,0}};
    }
    // Given the array of points it computes the actual diffing
    std::vector<std::pair<diff_type, std::string> > compute_diffs(std::vector<std::pair<int, int> > points) {
        diffs.clear();
        for (int i = 0; i < points.size(); i += 1) {
            diff_type type;
            if (i + 1 != points.size()) {
                if (points[i + 1].first > points[i].first && points[i + 1].second > points[i].second) {
                    type = diff_type::EQUAL;
                } else if (points[i + 1].first > points[i].first && points[i + 1].second == points[i].second) {
                    type = diff_type::ERASE;
                } else if (points[i + 1].second > points[i].second && points[i + 1].first == points[i].first) {
                    type = diff_type::INSERT;
                }
            } else {
                break;
            }
            int startA = points[i].first;
            int startB = points[i].second;
            if (type == diff_type::EQUAL) {
                while (i + 1 < points.size() && points[i + 1].first > points[i].first && points[i + 1].second > points[i].second) {
                    i += 1;
                }
            } else if (type == diff_type::ERASE) {
                while (i + 1 < points.size() && points[i + 1].first > points[i].first && points[i + 1].second == points[i].second) {
                    i += 1;
                }
            } else if (type == diff_type::INSERT) {
                while (i + 1 < points.size() && points[i + 1].second > points[i].second && points[i + 1].first == points[i].first) {
                    i += 1;
                }
            }
            int endA = points[i].first;
            int endB = points[i].second;
            i--;
            if (startA < endA) {
                diffs.push_back({type, textA.substr(startA + 1, endA - startA)});
            } else if (startB < endB) {
                diffs.push_back({type, textB.substr(startB + 1, endB - startB)});
            }
        }
        return diffs;
    }
  public:
    // Returns an array of diff chunks.
    // Each chunk has a type (equal, insert or erase) and the string chunk
    std::vector<std::pair<diff_type, std::string> > MakeDiff(std::string A, std::string B) {
        textA = A;
        textB = B;

        return compute_diffs(compute_snake(textA, textB));
    }
    // Make diffs from last texts
    std::vector<std::pair<diff_type, std::string> > MakeDiff() {
        return compute_diffs(compute_snake(textA, textB));
    }
    // Make diff directly as a string
    std::string MakeDiffString(std::string A, std::string B) {
        std::string diff_string = "";
        MakeDiff(A, B);
        for (auto &it : diffs) {
            if (it.first == diff_type::EQUAL) {
                diff_string += "=\n";
            } else if (it.first == diff_type::INSERT){
                diff_string += "+\n";
            } else {
                diff_string += "-\n";
            }
            diff_string += it.second + "\n";
        }
        return diff_string;
    };
    // Same as up there but no arguments given
    std::string MakeDiffString() {
        return MakeDiffString(textA, textB);
    };
    // Getter for the first text given
    std::string GetTextA() {
        return textA;
    }
    // Getter for the second text given
    std::string GetTextB() {
        return textB;
    }
    // Getter for the last diffing made
    std::vector<std::pair<diff_type, std::string> > GetLastDiff() {
        return diffs;
    }
    // Default constructor
    Diff () {}
    // Constructor where texts are given
    Diff(std::string A, std::string B) {
        textA = A;
        textB = B;
    }
};
#endif // DIFF_HPP