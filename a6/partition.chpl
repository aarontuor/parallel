proc prefix_sum_partition(pivotVal) {
    var pivotrange = low..high;
    var pivotarr: [pivotrange] real;
    pivotarr[pivotrange] = pivotVal;
    var gt = A[pivotrange] > pivotarr;
    var lt = A[pivotrange] < pivotarr;
    var ltsum  = + scan A[low..high];
    var gtsum  = + scan A[low..high];
    var temparr = A[pivotrange];
    //forall i in pivotrange:


    //var gt: [low..high] int;
    //var ltsum: [low..high] int;
    //var gtsum: [low..high] int;
    //var prefix_sum = + scan A;
}
