"""
Serial in place bitonic merge sort implementation
"""

import random
import argparse

def return_parser():
    parser = argparse.ArgumentParser()
    parser.add_argument('n', type=int, help='Power of 2 number of values to sort.')
    parser.add_argument('ascending', type=int, help='1 for ascending sort, 0 for descending sort.')
    parser.add_argument('-verbose', action='store_true', help='Whether to print sorted list.')
    return parser

def bitonic_merge(numbers, begin, count, ascending):
    """
    Bitonic merge a list of number in place
    :param numbers:
    :param begin:
    :param count:
    :param ascending:
    """
    if count > 1:
        k = count/2
        for i in range(begin, begin + k):
            if ascending != int(numbers[i] <= numbers[i + k]):
                numbers[i], numbers[i + k] = numbers[i + k], numbers[i]
        bitonic_merge(numbers, begin, k, ascending)
        bitonic_merge(numbers, begin + k, k, ascending)



def bitonic_sort(numbers, begin, count, ascending):
    """
    Bitonic sort a list of numbers in place
    :param numbers:
    :param begin:
    :param count:
    :param ascending:
    """
    if count > 1:
        k = count/2
        bitonic_sort(numbers, begin, k, 1)
        bitonic_sort(numbers, begin + k, k, 0)
        bitonic_merge(numbers, begin, count, ascending)

if __name__ == '__main__':
    args = return_parser().parse_args()
    count = 2**args.n
    numbers = [random.randint(0, 5000) for i in range(count)]
    bitonic_sort(numbers, 0, count, args.ascending)
    if args.verbose:
        print(numbers)
