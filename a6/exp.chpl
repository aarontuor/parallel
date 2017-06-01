// Exploring distributions across locales with chapel

use Random;
use BlockDist;

config var n: int = 2**3;
const space = {1..n};
const D: domain(1) dmapped Block(boundingBox=space) = space;
var A: [D] int;
fillRandom(A);

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
writeln(A);
var prefix_sum = + scan A;
//  var maxScan = max scan listOfValues;
writeln(prefix_sum);
