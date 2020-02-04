// Code from Matthew Gilliard's blog article:
// https://blog.gilliard.lol/2017/10/02/JVM-startup.html
//
public class Convert {
  public static void main(String args[]) throws Throwable {
    int i;
    boolean inParams = false;
    while ((i = System.in.read()) >= 0) {
      switch (i) {
      case ':':
        continue; // skip
      case '/':
        if (!inParams) {
          i = '.';
        }
        break;
      case '(':
        inParams = true;
        break;
      case '\n':
      case '\r':
        inParams = false;
        break;
      }
      System.out.write(i);
    }
  }
}
