/*  _
** |_|___ ___
** | |_ -|_ -|
** |_|___|___|
**  iss(c)2020
**
**  public site: https://forum.defence-force.org/viewtopic.php?f=9&t=1699
**
**  Updated: 2020.10.05 - fixed bit operation - @john
**           2020.10.29 - fixed more bit operation - @thekorex
**           2021.11.14 - adapted for 4116 - @xouillet
*/

/* ================================================================== */
#include <SoftwareSerial.h>

#define DI          A0
#define DO          A1 
#define CAS         A2 
#define RAS         A3 
#define WE          A4 

#define XA0         0
#define XA1         1 
#define XA2         2
#define XA3         3
#define XA4         4
#define XA5         5
#define XA6         6

#define BUS_SIZE     7

/* ================================================================== */
volatile int bus_size;

const unsigned int a_bus[BUS_SIZE] = {
  XA0, XA1, XA2, XA3, XA4, XA5, XA6
};

void setBus(unsigned int a) {
  int i;
  for (i = 0; i < BUS_SIZE; i++) {
    digitalWrite(a_bus[i], a & 1);
    a /= 2;
  }
}

void writeAddress(unsigned int r, unsigned int c, int v) {
  /* row */
  setBus(r);
  digitalWrite(RAS, LOW);

  /* rw */
  digitalWrite(WE, LOW);

  /* val */
  digitalWrite(DI, (v & 1)? HIGH : LOW);

  /* col */
  setBus(c);
  digitalWrite(CAS, LOW);

  digitalWrite(WE, HIGH);
  digitalWrite(CAS, HIGH);
  digitalWrite(RAS, HIGH);
}

int readAddress(unsigned int r, unsigned int c) {
  int ret = 0;

  /* row */
  setBus(r);
  digitalWrite(RAS, LOW);

  /* col */
  setBus(c);
  digitalWrite(CAS, LOW);

  /* get current value */
  ret = digitalRead(DO);

  digitalWrite(CAS, HIGH);
  digitalWrite(RAS, HIGH);

  return ret;
}

void error(int r, int c)
{
  unsigned long a = ((unsigned long)c << bus_size) + r;
  interrupts();
  Serial.print(" FAILED $");
  Serial.println(a, HEX);
  Serial.flush();
  while (1)
    ;
}

void ok(void)
{
  interrupts();
  Serial.println(" OK!");
  Serial.flush();
  while (1)
    ;
}

void fill(int v) {
  int r, c, g = 0;
  v &= 1;
  for (c = 0; c < (1<<bus_size); c++) {
    for (r = 0; r < (1<<bus_size); r++) {
      writeAddress(r, c, v);
      if (v != readAddress(r, c))
        error(r, c);
    }
    g ^= 1;
  }
}

void fillx(int v) {
  int r, c, g = 0;
  v &= 1;
  for (c = 0; c < (1<<bus_size); c++) {
    for (r = 0; r < (1<<bus_size); r++) {
      writeAddress(r, c, v);
      if (v != readAddress(r, c))
        error(r, c);
      v ^= 1;
    }
    g ^= 1;
  }
}

void setup() {
  int i;

  Serial.begin(9600);
  while (!Serial)
    ; /* wait */

  Serial.println();
  Serial.print("4116 TESTER ");

  for (i = 0; i < BUS_SIZE; i++)
    pinMode(a_bus[i], OUTPUT);

  pinMode(CAS, OUTPUT);
  pinMode(RAS, OUTPUT);
  pinMode(WE, OUTPUT);
  pinMode(DI, OUTPUT);
  pinMode(DO, INPUT);

  digitalWrite(WE, HIGH);
  digitalWrite(RAS, HIGH);
  digitalWrite(CAS, HIGH);

  noInterrupts();
  for (i = 0; i < (1 << BUS_SIZE); i++) {
    digitalWrite(RAS, LOW);
    digitalWrite(RAS, HIGH);
  }
}

void loop() {
  interrupts(); Serial.print("."); Serial.flush(); noInterrupts(); fillx(0);
  interrupts(); Serial.print("."); Serial.flush(); noInterrupts(); fillx(1);
  interrupts(); Serial.print("."); Serial.flush(); noInterrupts(); fill(0);
  interrupts(); Serial.print("."); Serial.flush(); noInterrupts(); fill(1);
  ok();
}
