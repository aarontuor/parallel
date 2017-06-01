"""
Serial quick sort implementation
"""

import random
import argparse
import numpy as np

def return_parser():
    parser = argparse.ArgumentParser()
    parser.add_argument('n', type=int, help='Power of 2 number of values to sort.')
    parser.add_argument('ascending', type=int, help='1 for ascending sort, 0 for descending sort.')
    parser.add_argument('-verbose', action='store_true', help='Whether to print sorted list.')
    return parser

def find_pivot(numbers, low):
    midval = numbers[low]
    lowval = numbers[low+1]
    highval = numbers[low+2]
    pivot = max([midval, lowval])
    return min([pivot, highval])

def partition(numbers, start, end, pivot):
    new_numbers = numbers[:]
    lt = [int(i < pivot) for i in numbers[start:end]]
    gt = [int(i > pivot) for i in numbers[start:end]]
    ltsum = [sum(lt[:i+1]) for i in range(len(lt))]
    gtsum = [sum(gt[:i+1]) for i in range(len(gt))]

    for idx, t in enumerate(lt):
        if t:
            numbers[ltsum[idx] - 1] = new_numbers[idx]
    mid = ltsum[-1]
    numbers[mid] = pivot
    for idx, t in enumerate(gt):
        if t:
            numbers[gtsum[idx] + mid] = new_numbers[idx]
    return mid
    print(lt)
    print(ltsum)
    print(gt)
    print(gtsum)
    print(numbers)

def quicksort(numbers):
    quick(numbers, 0, len(numbers))

def quick(numbers, start, end):
    if end - start <= 8:
        numbers[start:end] = sorted(numbers[start:end])
    else:
        pivotval = find_pivot(numbers, start)
        print(pivotval)
        pivotind = partition(numbers, start, end, pivotval)
        print(pivotind)
        quick(numbers, start, pivotind)
        quick(numbers, pivotind + 1, end)

if __name__ == '__main__':
    args = return_parser().parse_args()
    count = 2**args.n
    numbers = [random.randint(0, 5000) for i in range(count)]
    print(numbers)
    pivot = find_pivot(numbers, 0)
    print(pivot)
    partition(numbers, 0, len(numbers), pivot)
    print(sorted(numbers))
    quicksort(numbers)

    print(numbers)


# def quicksort(myList, start, end):
#     if start < end:
#         # partition the list
#         pivot = partition(myList, start, end)
#         # sort both halves
#         quicksort(myList, start, pivot-1)
#         quicksort(myList, pivot+1, end)
#     return myList
#
#
# def partition(myList, start, end):
#     pivot = myList[start]
#     left = start+1
#     right = end
#     done = False
#     while not done:
#         while left <= right and myList[left] <= pivot:
#             left = left + 1
#         while myList[right] >= pivot and right >=left:
#             right = right -1
#         if right < left:
#             done= True
#         else:
#             # swap places
#             temp=myList[left]
#             myList[left]=myList[right]
#             myList[right]=temp
#     # swap start with myList[right]
#     temp=myList[start]
#     myList[start]=myList[right]
#     myList[right]=temp
#     return right
