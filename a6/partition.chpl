use Random;
use BlockDist;
use VisualDebug;

config var num: int = 3;
var n: int = 2**num;
config var dir: int = 1;
var ascending: bool = if dir == 0 then false else true;
const space = {2..n+1};
const D: domain(1) dmapped Block(boundingBox=space) = space;
var A: [D] real;
//var A: [1..n] real;
fillRandom(A);


/*proc find_pivot(numbers: [], low:int){
    var midval = numbers[low];
    var lowval = numbers[low+1];
    var highval = numbers[low+2];
    var pivot = max(midval, lowval);
    return min(pivot, highval);
}*/

proc find_pivot(arr: [], low:int, high:int) {
  const mid = low + (high-low+1) / 2;

  if arr(mid) < arr(low) then arr(mid) <=> arr(low);
  if arr(high) < arr(low) then arr(high) <=> arr(low);
  if arr(high) < arr(mid) then arr(high) <=> arr(mid);

  const pivotVal = arr(mid);
  /*arr(mid) = arr(high-1);
  arr(high-1) = pivotVal;*/

  return pivotVal;
}

proc prefix_sum_partition(A: [], low: int, high: int, pivotval:real) {
    const pivotrange = low..high;
    var gt: [pivotrange] int;
    var lt: [pivotrange] int;
    forall i in pivotrange do {
        cobegin{
            if A[i] < pivotval then lt[i] = 1; else lt[i] = 0;
            if A[i] > pivotval then gt[i] = 1; else gt[i] = 0;
        }
    }
    var ltsum: [pivotrange] int;
    var gtsum: [pivotrange] int;

    ltsum  = + scan lt;
    gtsum  = + scan gt;
    ltsum += low-1;
    gtsum += ltsum[high] + 1;
    var temparr: [pivotrange] real;
    forall i in pivotrange{
        temparr[i] = A[i];
    }
    writeln(gt);
    writeln(gtsum[low..high]);
    writeln(lt);
    writeln(ltsum[low..high]);
    forall i in pivotrange do {
        cobegin{
            if lt[i] == 1 then A[i] = temparr[ltsum[i]];
            if gt[i] == 1 then A[i] = temparr[gtsum[i]];
        }
    }
    A[gtsum[low]] = pivotval;


    return;

}
writeln(A);
var pivot = find_pivot(A, A.domain.low, A.domain.high);
writeln((A.domain.low, A.domain.high));
prefix_sum_partition(A, A.domain.low, A.domain.high, pivot);
writeln(pivot);
writeln(A);
