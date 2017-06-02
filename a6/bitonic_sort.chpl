// Bitonic merge sort

use Random;
use BlockDist;
use VisualDebug;

config var n: int = 2**3;
config var dir: int = 1;
var ascending: bool = if dir == 0 then false else true;
const space = {1..n};
const D: domain(1) dmapped Block(boundingBox=space) = space;
var A: [D] real;
//var A: [1..n] real;
fillRandom(A);
writeln(A);

proc bitonic_merge(arr: [],
                   low: int,
                   count: int,
                   ascending: bool){
    if count > 1{
        const k = count/2;
        forall i in low..low+k-1{
            if ascending != arr[i] <= arr[i + k]{
                arr[i] <=> arr[i + k];
            }
        }
        //begin on arr(low) do {
            bitonic_merge(arr, low, k, ascending);
        //}
        //begin on arr(low+k) do {
            bitonic_merge(arr, low + k, k, ascending);
        //}
    }
    return;
}

proc bitonic_sort(arr: [],
                  low: int,
                  count: int,
                  ascending: bool){
    if count > 1 {
        const k = count/2;
        cobegin {
            on arr(low) do
                bitonic_sort(arr, low, k, true);
            on arr(low + k) do
                bitonic_sort(arr, low + k, k, false);
        }
        bitonic_merge(arr, low, count, ascending);
    }
    return;

}

startVdebug("BITONIC");
bitonic_sort(A, 1, n, ascending);
stopVdebug();
writeln(A);
forall i in 2..n do
  if A(i) < A(i-1) then
    halt("A(", i-1, ") == ", A(i-1), " > A(", i, ") == ", A(i));

writeln("verification success");

/*{
  var x: int = 2;

  on Locales[1 % numLocales] {
    var y: int = 3;

    on x do
      writeln("Using a data-driven on-clause, I'm now executing on locale ",
              here.id);
  }

  writeln();
}*/

/*var prefix_sum = + scan A;
//  var maxScan = max scan listOfValues;
writeln(prefix_sum);*/
