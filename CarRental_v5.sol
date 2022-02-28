{\rtf1\ansi\ansicpg1252\cocoartf2513
\cocoatextscaling0\cocoaplatform0{\fonttbl\f0\fnil\fcharset0 Menlo-Regular;}
{\colortbl;\red255\green255\blue255;\red79\green122\blue61;\red255\green255\blue255;\red172\green173\blue193;
\red71\green137\blue205;\red212\green212\blue212;\red167\green197\blue151;\red45\green175\blue118;\red238\green114\blue173;
\red17\green112\blue148;\red194\green126\blue101;\red252\green180\blue12;\red187\green96\blue43;\red139\green107\blue10;
\red31\green133\blue64;}
{\*\expandedcolortbl;;\cssrgb\c37609\c54466\c30476;\cssrgb\c100000\c100000\c100000\c0;\cssrgb\c73059\c73457\c80033;
\cssrgb\c33936\c61427\c84130;\cssrgb\c86370\c86370\c86262;\cssrgb\c71008\c80807\c65805;\cssrgb\c19586\c72947\c53683;\cssrgb\c95320\c54126\c73246;
\cssrgb\c3457\c51349\c64890;\cssrgb\c80778\c56830\c46925;\cssrgb\c99664\c75273\c2206;\cssrgb\c78724\c45738\c22110;\cssrgb\c61751\c49155\c2803;
\cssrgb\c12866\c57979\c31656;}
\paperw11900\paperh16840\margl1440\margr1440\vieww18940\viewh14280\viewkind0
\deftab720
\pard\pardeftab720\sl360\partightenfactor0

\f0\fs24 \cf2 \cb3 \expnd0\expndtw0\kerning0
\outl0\strokewidth0 \strokec2 // SPDX-License-Identifier: GPL-3.0\cf4 \strokec4 \
\cf5 \strokec5 pragma\cf4 \strokec4  \cf5 \strokec5 solidity\cf4 \strokec4  \cf6 \strokec6 >=\cf7 \strokec7 0.7.0\cf4 \strokec4  \cf6 \strokec6 <\cf7 \strokec7 0.9.0\cf6 \strokec6 ;\cf4 \strokec4 \
\
\cf2 \strokec2 /***************************************************************************************************************/\cf4 \strokec4 \
\cf2 \strokec2 /***************************************************************************************************************/\cf4 \strokec4 \
\cf2 \strokec2 /*  Contract to facilitate car rental              \cf4 \strokec4 \
\cf2 \strokec2 /*  Car type available:                            \cf4 \strokec4 \
\cf2 \strokec2 /*    a. 4-seater = 1 ETH/day                      \cf4 \strokec4 \
\cf2 \strokec2 /*    b. 6-seater = 2 ETH/day                      \cf4 \strokec4 \
\cf2 \strokec2 /*    c. 8-seater = 3 ETH/day \cf4 \strokec4 \
\cf2 \strokec2 /*\cf4 \strokec4 \
\cf2 \strokec2 /*  Process flow:\cf4 \strokec4 \
\cf2 \strokec2 /*    1. Company's wallet account deploys the contract \cf4 \strokec4 \
\cf2 \strokec2 /*    2. Listing of car fleet for rent \cf4 \strokec4 \
\cf2 \strokec2 /*       - only company's account can add\cf4 \strokec4 \
\cf2 \strokec2 /*       - 10ETH to be added into the contract for each car to instill confidence of availability\cf4 \strokec4 \
\cf2 \strokec2 /*    3. Customer check availability \cf4 \strokec4 \
\cf2 \strokec2 /*       - check that value in contract now matches number of cars available with ratio 1car:10ETH \cf4 \strokec4 \
\cf2 \strokec2 /*    4. Customer choose a available car to rent and deposit 10ETH per number of days intended to rent to show commitment. \cf4 \strokec4 \
\cf2 \strokec2 /*       - Will fail if user has a prior rental record that indicates existing outstanding fees. Proceed to pay fine if so.  \cf4 \strokec4 \
\cf2 \strokec2 /*    5. Once deposit received from customer, company release car key to customer and key in start date. Contract amount will be reduced.  \cf4 \strokec4 \
\cf2 \strokec2 /*    6. Car returned, company key in end date to calculate cost of rent base on days. Cost of any damage will be added to the total cost\cf4 \strokec4 \
\cf2 \strokec2 /*       - Deduct from deposit; if extra will be returned to customer, shortfall will be recorded as outstanding fees which until it is paid, \cf4 \strokec4 \
\cf2 \strokec2 /*         will not allow user to rent\cf4 \strokec4 \
\cf2 \strokec2 /*    7. Once done, avail the car by changing state to available \cf4 \strokec4 \
\cf2 \strokec2 /****************************************************************************************************************/\cf4 \strokec4 \
\cf2 \strokec2 /****************************************************************************************************************/\cf4 \strokec4 \
\
\cf5 \strokec5 contract\cf4 \strokec4  CarRental \cf6 \strokec6 \{\cf4 \strokec4 \
\
  \cf2 \strokec2 /********************************************************************************************************/\cf4 \strokec4 \
  \cf2 \strokec2 /*                                           Declarations                                               */\cf4 \strokec4 \
  \cf2 \strokec2 /********************************************************************************************************/\cf4 \strokec4 \
\
    \cf2 \strokec2 // Designing a structure to store the information of ABC Rental company's car fleet \cf4 \strokec4 \
    \cf5 \strokec5 struct\cf4 \strokec4  carInfo \cf6 \strokec6 \{\cf4 \strokec4 \
      \cf5 \strokec5 string\cf4 \strokec4  carPlate\cf6 \strokec6 ;\cf4 \strokec4  \
      \cf5 \strokec5 string\cf4 \strokec4  carInfo\cf6 \strokec6 ;\cf4 \strokec4  \cf2 \strokec2 // Short description about car\cf4 \strokec4 \
      \cf5 \strokec5 uint\cf4 \strokec4  carType\cf6 \strokec6 ;\cf4 \strokec4  \cf2 \strokec2 // How many seater: 4/6/8\cf4 \strokec4 \
      \cf5 \strokec5 bool\cf4 \strokec4  carAvailable\cf6 \strokec6 ;\cf4 \strokec4  \cf2 \strokec2 // True: Available, False: N.Available \cf4 \strokec4 \
    \cf6 \strokec6 \}\cf4 \strokec4 \
\
    \cf2 \strokec2 // Designing a structure to store the information of Customers.  \cf4 \strokec4 \
    \cf5 \strokec5 struct\cf4 \strokec4  customerInfo \cf6 \strokec6 \{\cf4 \strokec4 \
      \cf5 \strokec5 string\cf4 \strokec4  name\cf6 \strokec6 ;\cf4 \strokec4  \
      \cf5 \strokec5 string\cf4 \strokec4  identityNum\cf6 \strokec6 ;\cf4 \strokec4   \
      \cf5 \strokec5 uint\cf4 \strokec4  age\cf6 \strokec6 ;\cf4 \strokec4 \
      \cf5 \strokec5 string\cf4 \strokec4  resiAdd\cf6 \strokec6 ;\cf4 \strokec4  \cf2 \strokec2 // Residential address\cf4 \strokec4 \
      \cf5 \strokec5 address\cf4 \strokec4  walletAdd\cf6 \strokec6 ;\cf4 \strokec4  \cf2 \strokec2 // Wallet address of customer\cf4 \strokec4 \
    \cf6 \strokec6 \}\cf4 \strokec4 \
\
    \cf2 \strokec2 // Designing a structure to store the car renting history \cf4 \strokec4 \
    \cf5 \strokec5 struct\cf4 \strokec4  rentalHistory \cf6 \strokec6 \{\cf4 \strokec4 \
      \cf5 \strokec5 string\cf4 \strokec4  carPlate\cf6 \strokec6 ;\cf4 \strokec4  \
      \cf5 \strokec5 string\cf4 \strokec4  name\cf6 \strokec6 ;\cf4 \strokec4    \
      \cf5 \strokec5 address\cf4 \strokec4  walletAdd\cf6 \strokec6 ;\cf4 \strokec4 \
      \cf5 \strokec5 uint\cf4 \strokec4  depositAmt\cf6 \strokec6 ;\cf4 \strokec4 \
      \cf5 \strokec5 uint\cf4 \strokec4  startDate\cf6 \strokec6 ;\cf4 \strokec4   \
      \cf5 \strokec5 uint\cf4 \strokec4  endDate\cf6 \strokec6 ;\cf4 \strokec4 \
      \cf5 \strokec5 uint\cf4 \strokec4  numOfDays\cf6 \strokec6 ;\cf4 \strokec4  \cf2 \strokec2 // Number of days user intend to rent\cf4 \strokec4 \
      \cf5 \strokec5 bool\cf4 \strokec4  carReturned\cf6 \strokec6 ;\cf4 \strokec4 \
      \cf5 \strokec5 uint\cf4 \strokec4  outstandingFee\cf6 \strokec6 ;\cf4 \strokec4 \
      \cf6 \strokec6 \}\cf4 \strokec4 \
\
    \cf2 \strokec2 // enum State \{ Unavailable, Available \}\cf4 \strokec4 \
    \cf2 \strokec2 // State public carState;\cf4 \strokec4 \
    \cf5 \strokec5 address\cf4 \strokec4  \cf8 \strokec8 payable\cf4 \strokec4  \cf8 \strokec8 public\cf4 \strokec4  company\cf6 \strokec6 ;\cf4 \strokec4  \cf2 \strokec2 // the address of the company's account\cf4 \strokec4 \
    \cf5 \strokec5 uint\cf4 \strokec4  \cf8 \strokec8 public\cf4 \strokec4  contractBalance \cf6 \strokec6 =\cf4 \strokec4  \cf7 \strokec7 0\cf6 \strokec6 ;\cf4 \strokec4  \cf2 \strokec2 // to check the current balance in the contract if it matches availability of cars\cf4 \strokec4 \
    \cf5 \strokec5 uint\cf4 \strokec4  \cf8 \strokec8 public\cf4 \strokec4  carCnt \cf6 \strokec6 =\cf4 \strokec4  \cf7 \strokec7 0\cf6 \strokec6 ;\cf4 \strokec4  \cf2 \strokec2 // to count the number of the cars added\cf4 \strokec4 \
    \cf5 \strokec5 uint\cf4 \strokec4  \cf8 \strokec8 public\cf4 \strokec4  customerCnt \cf6 \strokec6 =\cf4 \strokec4  \cf7 \strokec7 0\cf6 \strokec6 ;\cf4 \strokec4  \cf2 \strokec2 // to count the number of the customers\cf4 \strokec4 \
    \cf5 \strokec5 uint\cf4 \strokec4  \cf8 \strokec8 public\cf4 \strokec4  recordCnt \cf6 \strokec6 =\cf4 \strokec4  \cf7 \strokec7 0\cf6 \strokec6 ;\cf4 \strokec4  \cf2 \strokec2 // to count the number of the rental records \cf4 \strokec4 \
\
    \cf5 \strokec5 mapping\cf6 \strokec6 (\cf5 \strokec5 uint\cf4 \strokec4  => carInfo\cf6 \strokec6 )\cf4 \strokec4  \cf8 \strokec8 public\cf4 \strokec4  cars\cf6 \strokec6 ;\cf4 \strokec4  \cf2 \strokec2 // to store the information of each car type\cf4 \strokec4 \
    \cf5 \strokec5 mapping\cf6 \strokec6 (\cf5 \strokec5 uint\cf4 \strokec4  => customerInfo\cf6 \strokec6 )\cf4 \strokec4  customers\cf6 \strokec6 ;\cf4 \strokec4  \cf2 \strokec2 // to store the information of each car type\cf4 \strokec4 \
    \cf5 \strokec5 mapping\cf6 \strokec6 (\cf5 \strokec5 uint\cf4 \strokec4  => rentalHistory\cf6 \strokec6 )\cf4 \strokec4  records\cf6 \strokec6 ;\cf4 \strokec4  \cf2 \strokec2 // to store the rental records: the customer address to the index of car he/she rent\cf4 \strokec4 \
\
\
  \cf2 \strokec2 /********************************************************************************************************/\cf4 \strokec4 \
  \cf2 \strokec2 /*                                           Constructor                                                */\cf4 \strokec4 \
  \cf2 \strokec2 /********************************************************************************************************/\cf4 \strokec4 \
\
    \cf9 \strokec9 constructor\cf6 \strokec6 ()\cf4 \strokec4  \cf8 \strokec8 payable\cf4 \strokec4  \cf6 \strokec6 \{\cf4 \strokec4 \
        company \cf6 \strokec6 =\cf4 \strokec4  \cf8 \strokec8 payable\cf6 \strokec6 (\cf10 \strokec10 msg\cf6 \strokec6 .\cf4 \strokec4 sender\cf6 \strokec6 );\cf4 \strokec4 \
    \cf6 \strokec6 \}\cf4 \strokec4 \
\
\
  \cf2 \strokec2 /********************************************************************************************************/\cf4 \strokec4 \
  \cf2 \strokec2 /*                                           Modifiers                                                  */\cf4 \strokec4 \
  \cf2 \strokec2 /********************************************************************************************************/\cf4 \strokec4 \
\
    \cf2 \strokec2 // To check msg.sender is the company\cf4 \strokec4 \
    \cf5 \strokec5 modifier\cf4 \strokec4  isCompany\cf6 \strokec6 ()\cf4 \strokec4  \cf6 \strokec6 \{\cf4 \strokec4 \
        \cf10 \strokec10 require\cf6 \strokec6 (\cf10 \strokec10 msg\cf6 \strokec6 .\cf4 \strokec4 sender \cf6 \strokec6 ==\cf4 \strokec4  company\cf6 \strokec6 ,\cf4 \strokec4  \cf11 \strokec11 "Only company can add car information."\cf6 \strokec6 );\cf4 \strokec4 \
        _\cf6 \strokec6 ;\cf4 \strokec4 \
    \cf6 \strokec6 \}\cf4 \strokec4 \
\
    \cf2 \strokec2 // To check critical car info entered is correct\cf4 \strokec4 \
    \cf5 \strokec5 modifier\cf4 \strokec4  infoCorrect\cf6 \strokec6 (\cf5 \strokec5 uint\cf4 \strokec4  seaterNum\cf6 \strokec6 ,\cf4 \strokec4  \cf5 \strokec5 uint\cf4 \strokec4  carStatus\cf6 \strokec6 )\cf4 \strokec4  \cf6 \strokec6 \{\cf4 \strokec4 \
        \cf5 \strokec5 bool\cf4 \strokec4  numvalid \cf6 \strokec6 =\cf4 \strokec4  \cf5 \strokec5 false\cf6 \strokec6 ;\cf4 \strokec4 \
        \cf5 \strokec5 bool\cf4 \strokec4  statusvalid \cf6 \strokec6 =\cf4 \strokec4  \cf5 \strokec5 false\cf6 \strokec6 ;\cf4 \strokec4 \
        \cf12 \strokec12 if\cf4 \strokec4  \cf6 \strokec6 (\cf4 \strokec4 seaterNum \cf6 \strokec6 ==\cf4 \strokec4  \cf7 \strokec7 4\cf4 \strokec4  \cf6 \strokec6 ||\cf4 \strokec4  seaterNum \cf6 \strokec6 ==\cf4 \strokec4  \cf7 \strokec7 6\cf4 \strokec4  \cf6 \strokec6 ||\cf4 \strokec4  seaterNum \cf6 \strokec6 ==\cf4 \strokec4  \cf7 \strokec7 8\cf6 \strokec6 )\cf4 \strokec4  \cf6 \strokec6 \{\cf4 \strokec4 \
            numvalid \cf6 \strokec6 =\cf4 \strokec4  \cf5 \strokec5 true\cf6 \strokec6 ;\cf4 \strokec4 \
        \cf6 \strokec6 \}\cf4 \strokec4 \
\
        \cf12 \strokec12 if\cf4 \strokec4  \cf6 \strokec6 (\cf4 \strokec4 carStatus \cf6 \strokec6 ==\cf4 \strokec4  \cf7 \strokec7 0\cf4 \strokec4  \cf6 \strokec6 ||\cf4 \strokec4  carStatus \cf6 \strokec6 ==\cf4 \strokec4  \cf7 \strokec7 1\cf6 \strokec6 )\cf4 \strokec4  \cf6 \strokec6 \{\cf4 \strokec4 \
            statusvalid \cf6 \strokec6 =\cf4 \strokec4  \cf5 \strokec5 true\cf6 \strokec6 ;\cf4 \strokec4 \
        \cf6 \strokec6 \}\cf4 \strokec4 \
        \cf10 \strokec10 require\cf6 \strokec6 (\cf4 \strokec4 numvalid \cf6 \strokec6 ==\cf4 \strokec4  \cf5 \strokec5 true\cf6 \strokec6 ,\cf4 \strokec4  \cf11 \strokec11 "Seater options is only 4, 6 or 8"\cf6 \strokec6 );\cf4 \strokec4 \
        \cf10 \strokec10 require\cf6 \strokec6 (\cf4 \strokec4 statusvalid \cf6 \strokec6 ==\cf4 \strokec4  \cf5 \strokec5 true\cf6 \strokec6 ,\cf4 \strokec4  \cf11 \strokec11 "Car Status 0:Unavailable, 1:Available"\cf6 \strokec6 );\cf4 \strokec4 \
        _\cf6 \strokec6 ;\cf4 \strokec4 \
    \cf6 \strokec6 \}\cf4 \strokec4 \
\
    \cf2 \strokec2 // To check the car is available\cf4 \strokec4 \
    \cf5 \strokec5 modifier\cf4 \strokec4  isAvailable\cf6 \strokec6 (\cf5 \strokec5 uint\cf4 \strokec4  typeId\cf6 \strokec6 )\cf4 \strokec4  \cf6 \strokec6 \{\cf4 \strokec4 \
      \cf10 \strokec10 require\cf6 \strokec6 (\cf4 \strokec4 cars\cf6 \strokec6 [\cf4 \strokec4 typeId\cf6 \strokec6 ].\cf4 \strokec4 carAvailable \cf6 \strokec6 ==\cf4 \strokec4  \cf5 \strokec5 true\cf6 \strokec6 ,\cf4 \strokec4  \cf11 \strokec11 "This car is not available, choose another one!"\cf6 \strokec6 );\cf4 \strokec4 \
      _\cf6 \strokec6 ;\cf4 \strokec4 \
    \cf6 \strokec6 \}\cf4 \strokec4 \
    \
    \cf2 \strokec2 // To check the msg.value is twice of the rent\cf4 \strokec4 \
    \cf5 \strokec5 modifier\cf4 \strokec4  isEnough\cf6 \strokec6 (\cf5 \strokec5 uint\cf4 \strokec4  numOfDays\cf6 \strokec6 )\cf4 \strokec4  \cf6 \strokec6 \{\cf4 \strokec4 \
      \cf10 \strokec10 require\cf6 \strokec6 (\cf10 \strokec10 msg\cf6 \strokec6 .\cf4 \strokec4 value \cf6 \strokec6 >=\cf4 \strokec4  \cf7 \strokec7 10\cf4 \strokec4  wei \cf6 \strokec6 *\cf4 \strokec4  numOfDays\cf6 \strokec6 ,\cf4 \strokec4  \cf11 \strokec11 "ETH Value sent in is not enough for deposit for the number of days intended to rent."\cf6 \strokec6 );\cf4 \strokec4 \
      _\cf6 \strokec6 ;\cf4 \strokec4 \
    \cf6 \strokec6 \}\cf4 \strokec4 \
\
    \cf2 \strokec2 // To check the renter has no past outstanding fees before renting\cf4 \strokec4 \
    \cf5 \strokec5 modifier\cf4 \strokec4  noOutstanding\cf6 \strokec6 (\cf5 \strokec5 address\cf4 \strokec4  walletAddress\cf6 \strokec6 )\cf4 \strokec4  \cf6 \strokec6 \{\cf4 \strokec4 \
      \cf5 \strokec5 bool\cf4 \strokec4  pass \cf6 \strokec6 =\cf4 \strokec4  \cf5 \strokec5 true\cf6 \strokec6 ;\cf4 \strokec4 \
\
      \cf13 \strokec13 for\cf4 \strokec4  \cf6 \strokec6 (\cf5 \strokec5 uint\cf4 \strokec4  i \cf6 \strokec6 =\cf4 \strokec4  recordCnt\cf6 \strokec6 ;\cf4 \strokec4  i \cf6 \strokec6 >\cf4 \strokec4  \cf7 \strokec7 0\cf6 \strokec6 ;\cf4 \strokec4  i\cf6 \strokec6 --)\cf4 \strokec4  \cf6 \strokec6 \{\cf4 \strokec4 \
        \cf12 \strokec12 if\cf4 \strokec4  \cf6 \strokec6 (\cf4 \strokec4 records\cf6 \strokec6 [\cf4 \strokec4 i\cf6 \strokec6 -\cf7 \strokec7 1\cf6 \strokec6 ].\cf4 \strokec4 walletAdd \cf6 \strokec6 ==\cf4 \strokec4  walletAddress\cf6 \strokec6 )\cf4 \strokec4  \cf6 \strokec6 \{\cf4 \strokec4 \
          \cf12 \strokec12 if\cf4 \strokec4  \cf6 \strokec6 (\cf4 \strokec4 records\cf6 \strokec6 [\cf4 \strokec4 i\cf6 \strokec6 -\cf7 \strokec7 1\cf6 \strokec6 ].\cf4 \strokec4 outstandingFee \cf6 \strokec6 !=\cf4 \strokec4  \cf7 \strokec7 0\cf6 \strokec6 )\cf4 \strokec4  \cf6 \strokec6 \{\cf4 \strokec4 \
            \cf2 \strokec2 // If the latest record available for this wallet address shows outstanding fee, renter is not allowed to rent\cf4 \strokec4 \
            pass \cf6 \strokec6 =\cf4 \strokec4  \cf5 \strokec5 false\cf6 \strokec6 ;\cf4 \strokec4 \
            \cf13 \strokec13 break\cf6 \strokec6 ;\cf4 \strokec4 \
          \cf6 \strokec6 \}\cf4 \strokec4 \
          \cf12 \strokec12 else\cf4 \strokec4  \cf12 \strokec12 if\cf4 \strokec4  \cf6 \strokec6 (\cf4 \strokec4 records\cf6 \strokec6 [\cf4 \strokec4 i\cf6 \strokec6 -\cf7 \strokec7 1\cf6 \strokec6 ].\cf4 \strokec4 outstandingFee \cf6 \strokec6 ==\cf4 \strokec4  \cf7 \strokec7 0\cf6 \strokec6 )\cf4 \strokec4  \cf6 \strokec6 \{\cf4 \strokec4 \
            \cf2 \strokec2 // If the latest record available for this wallet address shows no outstanding fee, no need to check earlier records anymore.\cf4 \strokec4 \
            pass \cf6 \strokec6 =\cf4 \strokec4  \cf5 \strokec5 true\cf6 \strokec6 ;\cf4 \strokec4 \
            \cf13 \strokec13 break\cf6 \strokec6 ;\cf4 \strokec4 \
          \cf6 \strokec6 \}\cf4 \strokec4 \
        \cf6 \strokec6 \}\cf4 \strokec4 \
        \cf12 \strokec12 else\cf4 \strokec4  \cf12 \strokec12 if\cf4 \strokec4  \cf6 \strokec6 (\cf4 \strokec4 i\cf6 \strokec6 ==\cf7 \strokec7 0\cf6 \strokec6 )\cf4 \strokec4  \cf6 \strokec6 \{\cf4 \strokec4 \
          \cf2 \strokec2 // No record of this wallet add yet, proceed to rent car\cf4 \strokec4 \
          pass \cf6 \strokec6 =\cf4 \strokec4  \cf5 \strokec5 true\cf6 \strokec6 ;\cf4 \strokec4 \
        \cf6 \strokec6 \}\cf4 \strokec4 \
      \cf6 \strokec6 \}\cf4 \strokec4 \
      \cf10 \strokec10 require\cf6 \strokec6 (\cf4 \strokec4 pass \cf6 \strokec6 ==\cf4 \strokec4  \cf5 \strokec5 true\cf6 \strokec6 ,\cf4 \strokec4  \cf11 \strokec11 "You have outstanding fees from previous rental, please proceed to pay your fee using pay fee function!"\cf6 \strokec6 );\cf4 \strokec4 \
      _\cf6 \strokec6 ;\cf4 \strokec4 \
    \cf6 \strokec6 \}\cf4 \strokec4 \
\
\
\
  \cf2 \strokec2 /********************************************************************************************************/\cf4 \strokec4 \
  \cf2 \strokec2 /*                                           Functions                                                  */\cf4 \strokec4 \
  \cf2 \strokec2 /********************************************************************************************************/\cf4 \strokec4 \
\
    \cf2 \strokec2 // Flow 2: Listing of car fleet for rent  \cf4 \strokec4 \
    \cf2 \strokec2 // The company should add information of the car type\cf4 \strokec4 \
    \cf5 \strokec5 function\cf4 \strokec4  addCarInfo\cf6 \strokec6 (\cf5 \strokec5 string\cf4 \strokec4  \cf14 \strokec14 memory\cf4 \strokec4  carPlateNum\cf6 \strokec6 ,\cf4 \strokec4  \cf5 \strokec5 string\cf4 \strokec4  \cf14 \strokec14 memory\cf4 \strokec4  carDescription\cf6 \strokec6 ,\cf4 \strokec4  \cf5 \strokec5 uint\cf4 \strokec4  seaterNum\cf6 \strokec6 ,\cf4 \strokec4  \cf5 \strokec5 uint\cf4 \strokec4  carStatus\cf6 \strokec6 )\cf4 \strokec4  \
    \cf8 \strokec8 payable\cf4 \strokec4  \cf8 \strokec8 public\cf4 \strokec4  isCompany infoCorrect\cf6 \strokec6 (\cf4 \strokec4 seaterNum\cf6 \strokec6 ,\cf4 \strokec4  carStatus\cf6 \strokec6 )\cf4 \strokec4  \cf6 \strokec6 \{\cf4 \strokec4 \
        \cf5 \strokec5 bool\cf4 \strokec4  carAvail \cf6 \strokec6 =\cf4 \strokec4  \cf5 \strokec5 false\cf6 \strokec6 ;\cf4 \strokec4 \
        \cf5 \strokec5 bool\cf4 \strokec4  unique \cf6 \strokec6 =\cf4 \strokec4  \cf5 \strokec5 true\cf6 \strokec6 ;\cf4 \strokec4 \
        \cf12 \strokec12 if\cf4 \strokec4  \cf6 \strokec6 (\cf4 \strokec4 carStatus \cf6 \strokec6 ==\cf4 \strokec4  \cf7 \strokec7 1\cf6 \strokec6 )\cf4 \strokec4  \cf6 \strokec6 \{\cf4 \strokec4 \
            carAvail \cf6 \strokec6 =\cf4 \strokec4  \cf5 \strokec5 true\cf6 \strokec6 ;\cf4 \strokec4 \
        \cf6 \strokec6 \}\cf4 \strokec4 \
\
        \cf2 \strokec2 // Convert carplate to lowercase, then compare with existing cars list to make sure we dont list the same car twice\cf4 \strokec4 \
        \cf13 \strokec13 for\cf4 \strokec4  \cf6 \strokec6 (\cf5 \strokec5 uint\cf4 \strokec4  i \cf6 \strokec6 =\cf4 \strokec4  \cf7 \strokec7 0\cf6 \strokec6 ;\cf4 \strokec4  i \cf6 \strokec6 <\cf4 \strokec4  carCnt\cf6 \strokec6 +\cf7 \strokec7 1\cf6 \strokec6 ;\cf4 \strokec4  i\cf6 \strokec6 ++)\cf4 \strokec4  \cf6 \strokec6 \{\cf4 \strokec4 \
            \cf12 \strokec12 if\cf4 \strokec4  \cf6 \strokec6 (\cf10 \strokec10 keccak256\cf6 \strokec6 (\cf10 \strokec10 bytes\cf6 \strokec6 (\cf4 \strokec4 _toLower\cf6 \strokec6 (\cf4 \strokec4 cars\cf6 \strokec6 [\cf4 \strokec4 i\cf6 \strokec6 ].\cf4 \strokec4 carPlate\cf6 \strokec6 )))\cf4 \strokec4  \cf6 \strokec6 ==\cf4 \strokec4  \cf10 \strokec10 keccak256\cf6 \strokec6 (\cf10 \strokec10 bytes\cf6 \strokec6 (\cf4 \strokec4 _toLower\cf6 \strokec6 (\cf4 \strokec4 carPlateNum\cf6 \strokec6 ))))\cf4 \strokec4  \cf6 \strokec6 \{\cf4 \strokec4 \
                unique \cf6 \strokec6 =\cf4 \strokec4  \cf5 \strokec5 false\cf6 \strokec6 ;\cf4 \strokec4 \
                \cf13 \strokec13 break\cf6 \strokec6 ;\cf4 \strokec4  \
            \cf6 \strokec6 \}\cf4 \strokec4 \
        \cf6 \strokec6 \}\cf4 \strokec4 \
        \cf10 \strokec10 require\cf6 \strokec6 (\cf4 \strokec4 unique \cf6 \strokec6 ==\cf4 \strokec4  \cf5 \strokec5 true\cf6 \strokec6 ,\cf4 \strokec4  \cf11 \strokec11 "You have added this car plate before!"\cf6 \strokec6 );\cf4 \strokec4 \
        \cf10 \strokec10 require\cf6 \strokec6 (\cf10 \strokec10 msg\cf6 \strokec6 .\cf4 \strokec4 value \cf6 \strokec6 ==\cf4 \strokec4  \cf7 \strokec7 10\cf4 \strokec4  wei\cf6 \strokec6 ,\cf4 \strokec4  \cf11 \strokec11 "The company has to deposit 10 ETH to instill confidence of car availability!"\cf6 \strokec6 );\cf4 \strokec4 \
        \
        \cf2 \strokec2 // Update contract balance\cf4 \strokec4 \
        contractBalance \cf6 \strokec6 =\cf4 \strokec4  contractBalance \cf6 \strokec6 +\cf4 \strokec4  \cf10 \strokec10 msg\cf6 \strokec6 .\cf4 \strokec4 value\cf6 \strokec6 ;\cf4 \strokec4 \
\
        \cf2 \strokec2 // Only add if verified car plate has never been uploaded before\cf4 \strokec4 \
        cars\cf6 \strokec6 [\cf4 \strokec4 carCnt\cf6 \strokec6 ]\cf4 \strokec4  \cf6 \strokec6 =\cf4 \strokec4  carInfo\cf6 \strokec6 (\cf4 \strokec4 carPlateNum\cf6 \strokec6 ,\cf4 \strokec4  carDescription\cf6 \strokec6 ,\cf4 \strokec4  seaterNum\cf6 \strokec6 ,\cf4 \strokec4  carAvail\cf6 \strokec6 );\cf4 \strokec4 \
        carCnt\cf6 \strokec6 ++;\cf4 \strokec4 \
    \cf6 \strokec6 \}\cf4 \strokec4 \
\
\
    \cf2 \strokec2 // Flow 3: Check availability  \cf4 \strokec4 \
    \cf5 \strokec5 function\cf4 \strokec4  carID_checkAvailability\cf6 \strokec6 (\cf5 \strokec5 uint\cf4 \strokec4  seaterNum\cf6 \strokec6 )\cf4 \strokec4  \
    \cf8 \strokec8 public\cf4 \strokec4  \cf8 \strokec8 view\cf4 \strokec4  \cf15 \strokec15 returns\cf6 \strokec6 (\cf4 \strokec4  \cf5 \strokec5 uint\cf6 \strokec6 []\cf4 \strokec4  \cf14 \strokec14 memory\cf6 \strokec6 )\cf4 \strokec4  \cf6 \strokec6 \{\cf4 \strokec4 \
      \cf2 \strokec2 // Allow user to input preference base on seater number, then we loop       \cf4 \strokec4 \
      \cf2 \strokec2 // through the dynamic list: cars, and output all those that carAvailabile = true\cf4 \strokec4 \
      \cf2 \strokec2 // Also to provide total contract balance to see if it matches the number of cars available for confidence\cf4 \strokec4 \
      \cf10 \strokec10 require\cf6 \strokec6 (\cf4 \strokec4 seaterNum \cf6 \strokec6 ==\cf4 \strokec4  \cf7 \strokec7 4\cf4 \strokec4  \cf6 \strokec6 ||\cf4 \strokec4  seaterNum \cf6 \strokec6 ==\cf4 \strokec4  \cf7 \strokec7 6\cf4 \strokec4  \cf6 \strokec6 ||\cf4 \strokec4  seaterNum \cf6 \strokec6 ==\cf7 \strokec7 8\cf6 \strokec6 ,\cf4 \strokec4  \cf11 \strokec11 "We only have 4/6/8-seater cars! "\cf6 \strokec6 );\cf4 \strokec4 \
      \cf10 \strokec10 require\cf6 \strokec6 (\cf4 \strokec4 carCnt \cf6 \strokec6 >\cf4 \strokec4  \cf7 \strokec7 0\cf6 \strokec6 ,\cf4 \strokec4  \cf11 \strokec11 "No cars listed yet!"\cf6 \strokec6 );\cf4 \strokec4 \
\
      \cf5 \strokec5 uint\cf4 \strokec4  resultCount\cf6 \strokec6 ;\cf4 \strokec4 \
      \cf13 \strokec13 for\cf4 \strokec4  \cf6 \strokec6 (\cf5 \strokec5 uint\cf4 \strokec4  i \cf6 \strokec6 =\cf4 \strokec4  \cf7 \strokec7 0\cf6 \strokec6 ;\cf4 \strokec4  i \cf6 \strokec6 <\cf4 \strokec4  carCnt\cf6 \strokec6 +\cf7 \strokec7 1\cf6 \strokec6 ;\cf4 \strokec4  i\cf6 \strokec6 ++)\cf4 \strokec4  \cf6 \strokec6 \{\cf4 \strokec4 \
        \cf12 \strokec12 if\cf4 \strokec4  \cf6 \strokec6 (\cf4 \strokec4 cars\cf6 \strokec6 [\cf4 \strokec4 i\cf6 \strokec6 ].\cf4 \strokec4 carAvailable \cf6 \strokec6 &&\cf4 \strokec4  cars\cf6 \strokec6 [\cf4 \strokec4 i\cf6 \strokec6 ].\cf4 \strokec4 carType \cf6 \strokec6 ==\cf4 \strokec4  seaterNum\cf6 \strokec6 )\cf4 \strokec4  \cf6 \strokec6 \{\cf4 \strokec4 \
          resultCount\cf6 \strokec6 ++;\cf4 \strokec4     \cf2 \strokec2 // determine the result count\cf4 \strokec4 \
        \cf6 \strokec6 \}\cf4 \strokec4 \
      \cf6 \strokec6 \}\cf4 \strokec4 \
      \
      \cf2 \strokec2 //create the fixed-length array\cf4 \strokec4 \
      \cf5 \strokec5 uint\cf6 \strokec6 []\cf4 \strokec4  \cf14 \strokec14 memory\cf4 \strokec4  result \cf6 \strokec6 =\cf4 \strokec4  \cf5 \strokec5 new\cf4 \strokec4  \cf5 \strokec5 uint\cf6 \strokec6 [](\cf4 \strokec4 resultCount\cf6 \strokec6 );\cf4 \strokec4  \
      \cf5 \strokec5 uint\cf4 \strokec4  j\cf6 \strokec6 ;\cf4 \strokec4 \
      \cf13 \strokec13 for\cf4 \strokec4  \cf6 \strokec6 (\cf5 \strokec5 uint\cf4 \strokec4  i \cf6 \strokec6 =\cf4 \strokec4  \cf7 \strokec7 0\cf6 \strokec6 ;\cf4 \strokec4  i \cf6 \strokec6 <\cf4 \strokec4  carCnt\cf6 \strokec6 +\cf7 \strokec7 1\cf6 \strokec6 ;\cf4 \strokec4  i\cf6 \strokec6 ++)\cf4 \strokec4  \cf6 \strokec6 \{\cf4 \strokec4 \
        \cf12 \strokec12 if\cf4 \strokec4  \cf6 \strokec6 (\cf4 \strokec4 cars\cf6 \strokec6 [\cf4 \strokec4 i\cf6 \strokec6 ].\cf4 \strokec4 carAvailable \cf6 \strokec6 &&\cf4 \strokec4  cars\cf6 \strokec6 [\cf4 \strokec4 i\cf6 \strokec6 ].\cf4 \strokec4 carType \cf6 \strokec6 ==\cf4 \strokec4  seaterNum\cf6 \strokec6 )\cf4 \strokec4  \cf6 \strokec6 \{\cf4 \strokec4 \
          result\cf6 \strokec6 [\cf4 \strokec4 j\cf6 \strokec6 ++]\cf4 \strokec4  \cf6 \strokec6 =\cf4 \strokec4  i\cf6 \strokec6 ;\cf4 \strokec4     \cf2 \strokec2 // fill the array\cf4 \strokec4 \
        \cf6 \strokec6 \}\cf4 \strokec4 \
      \cf6 \strokec6 \}\cf4 \strokec4 \
      \
      \cf2 \strokec2 // Output: recommendation of cars typeId list (index number) e.g 2,3,5\cf4 \strokec4 \
      \cf15 \strokec15 return\cf4 \strokec4  result\cf6 \strokec6 ;\cf4 \strokec4 \
    \cf6 \strokec6 \}\cf4 \strokec4 \
\
\
    \cf2 \strokec2 // Flow 4 & 5: Choose car that is available, Once deposit received from customer, company release car key to customer and key in start date. Contract amount will be reduced.\cf4 \strokec4 \
    \cf2 \strokec2 // The customer should deposit 10ETH * num of days they intend to rent \cf4 \strokec4 \
    \cf5 \strokec5 function\cf4 \strokec4  rentCar\cf6 \strokec6 (\cf5 \strokec5 uint\cf4 \strokec4  carID\cf6 \strokec6 ,\cf4 \strokec4  \cf5 \strokec5 uint\cf4 \strokec4  duration\cf6 \strokec6 ,\cf4 \strokec4  \cf5 \strokec5 string\cf4 \strokec4  \cf14 \strokec14 memory\cf4 \strokec4  Name\cf6 \strokec6 ,\cf4 \strokec4 \
      \cf5 \strokec5 string\cf4 \strokec4  \cf14 \strokec14 memory\cf4 \strokec4  IDnum\cf6 \strokec6 ,\cf4 \strokec4  \cf5 \strokec5 uint\cf4 \strokec4  age\cf6 \strokec6 ,\cf4 \strokec4  \cf5 \strokec5 string\cf4 \strokec4  \cf14 \strokec14 memory\cf4 \strokec4  resiAddress\cf6 \strokec6 ,\cf4 \strokec4  \cf5 \strokec5 address\cf4 \strokec4  walletAddress\cf6 \strokec6 )\cf4 \strokec4  \
      \cf8 \strokec8 payable\cf4 \strokec4  \cf8 \strokec8 public\cf4 \strokec4  isAvailable\cf6 \strokec6 (\cf4 \strokec4 carID\cf6 \strokec6 )\cf4 \strokec4  isEnough\cf6 \strokec6 (\cf4 \strokec4 duration\cf6 \strokec6 )\cf4 \strokec4  noOutstanding\cf6 \strokec6 (\cf10 \strokec10 msg\cf6 \strokec6 .\cf4 \strokec4 sender\cf6 \strokec6 )\cf4 \strokec4  \cf6 \strokec6 \{\cf4 \strokec4 \
        \cf10 \strokec10 require\cf6 \strokec6 (\cf4 \strokec4 walletAddress \cf6 \strokec6 ==\cf4 \strokec4  \cf10 \strokec10 msg\cf6 \strokec6 .\cf4 \strokec4 sender\cf6 \strokec6 ,\cf4 \strokec4  \cf11 \strokec11 "You must rent car using your own wallet address!"\cf6 \strokec6 );\cf4 \strokec4 \
        \cf10 \strokec10 require\cf6 \strokec6 (\cf4 \strokec4 age \cf6 \strokec6 >=\cf4 \strokec4  \cf7 \strokec7 21\cf6 \strokec6 ,\cf4 \strokec4  \cf11 \strokec11 "You must be at least 21 years old to rent a car!"\cf6 \strokec6 );\cf4 \strokec4 \
        \cf10 \strokec10 require\cf6 \strokec6 (\cf4 \strokec4 cars\cf6 \strokec6 [\cf4 \strokec4 carID\cf6 \strokec6 ].\cf4 \strokec4 carAvailable \cf6 \strokec6 ==\cf4 \strokec4  \cf5 \strokec5 true\cf6 \strokec6 ,\cf4 \strokec4  \cf11 \strokec11 "This car is currently not available, use carID_checkAvailability to find out which carID is available!"\cf6 \strokec6 );\cf4 \strokec4 \
\
        \cf2 \strokec2 // Update contract balance\cf4 \strokec4 \
        contractBalance \cf6 \strokec6 =\cf4 \strokec4  contractBalance \cf6 \strokec6 +\cf4 \strokec4  \cf10 \strokec10 msg\cf6 \strokec6 .\cf4 \strokec4 value\cf6 \strokec6 ;\cf4 \strokec4 \
\
        \cf5 \strokec5 bool\cf4 \strokec4  unique \cf6 \strokec6 =\cf4 \strokec4  \cf5 \strokec5 true\cf6 \strokec6 ;\cf4 \strokec4 \
        \cf2 \strokec2 // uint start = block.timestamp;\cf4 \strokec4 \
        \cf2 \strokec2 // uint end = start + (duration * 1 days);\cf4 \strokec4 \
        \
        \cf2 \strokec2 // Customer database: Record customer info if unique\cf4 \strokec4 \
        \cf13 \strokec13 for\cf4 \strokec4  \cf6 \strokec6 (\cf5 \strokec5 uint\cf4 \strokec4  i \cf6 \strokec6 =\cf4 \strokec4  \cf7 \strokec7 0\cf6 \strokec6 ;\cf4 \strokec4  i \cf6 \strokec6 <\cf4 \strokec4  customerCnt\cf6 \strokec6 +\cf7 \strokec7 1\cf6 \strokec6 ;\cf4 \strokec4  i\cf6 \strokec6 ++)\cf4 \strokec4  \cf6 \strokec6 \{\cf4 \strokec4 \
          \cf12 \strokec12 if\cf4 \strokec4  \cf6 \strokec6 (\cf10 \strokec10 keccak256\cf6 \strokec6 (\cf10 \strokec10 bytes\cf6 \strokec6 (\cf4 \strokec4 _toLower\cf6 \strokec6 (\cf4 \strokec4 customers\cf6 \strokec6 [\cf4 \strokec4 i\cf6 \strokec6 ].\cf4 \strokec4 identityNum\cf6 \strokec6 )))\cf4 \strokec4  \cf6 \strokec6 ==\cf4 \strokec4  \cf10 \strokec10 keccak256\cf6 \strokec6 (\cf10 \strokec10 bytes\cf6 \strokec6 (\cf4 \strokec4 _toLower\cf6 \strokec6 (\cf4 \strokec4 IDnum\cf6 \strokec6 ))))\cf4 \strokec4  \cf6 \strokec6 \{\cf4 \strokec4 \
            unique \cf6 \strokec6 =\cf4 \strokec4  \cf5 \strokec5 false\cf6 \strokec6 ;\cf4 \strokec4 \
            \cf13 \strokec13 break\cf6 \strokec6 ;\cf4 \strokec4 \
          \cf6 \strokec6 \}\cf4 \strokec4 \
        \cf6 \strokec6 \}\cf4 \strokec4 \
        \cf12 \strokec12 if\cf4 \strokec4  \cf6 \strokec6 (\cf4 \strokec4 unique\cf6 \strokec6 )\cf4 \strokec4  \cf6 \strokec6 \{\cf4 \strokec4 \
          customers\cf6 \strokec6 [\cf4 \strokec4 customerCnt\cf6 \strokec6 ]\cf4 \strokec4  \cf6 \strokec6 =\cf4 \strokec4  customerInfo\cf6 \strokec6 (\cf4 \strokec4 Name\cf6 \strokec6 ,\cf4 \strokec4  IDnum\cf6 \strokec6 ,\cf4 \strokec4  age\cf6 \strokec6 ,\cf4 \strokec4  resiAddress\cf6 \strokec6 ,\cf4 \strokec4  walletAddress\cf6 \strokec6 );\cf4 \strokec4 \
          customerCnt\cf6 \strokec6 ++;\cf4 \strokec4 \
        \cf6 \strokec6 \}\cf4 \strokec4 \
\
        \cf2 \strokec2 // Car Renting database: record cars that were rented and to which wallet address \cf4 \strokec4 \
        records\cf6 \strokec6 [\cf4 \strokec4 recordCnt\cf6 \strokec6 ]\cf4 \strokec4  \cf6 \strokec6 =\cf4 \strokec4  rentalHistory\cf6 \strokec6 (\cf4 \strokec4 cars\cf6 \strokec6 [\cf4 \strokec4 carID\cf6 \strokec6 ].\cf4 \strokec4 carPlate\cf6 \strokec6 ,\cf4 \strokec4  Name\cf6 \strokec6 ,\cf4 \strokec4  walletAddress\cf6 \strokec6 ,\cf4 \strokec4  \cf10 \strokec10 msg\cf6 \strokec6 .\cf4 \strokec4 value\cf6 \strokec6 ,\cf4 \strokec4  \cf10 \strokec10 block\cf6 \strokec6 .\cf4 \strokec4 timestamp\cf6 \strokec6 ,\cf4 \strokec4  \cf10 \strokec10 block\cf6 \strokec6 .\cf4 \strokec4 timestamp \cf6 \strokec6 +\cf4 \strokec4  \cf6 \strokec6 (\cf4 \strokec4 duration \cf6 \strokec6 *\cf4 \strokec4  \cf7 \strokec7 1\cf4 \strokec4  days\cf6 \strokec6 ),\cf4 \strokec4  duration\cf6 \strokec6 ,\cf4 \strokec4  \cf5 \strokec5 false\cf6 \strokec6 ,\cf4 \strokec4  \cf7 \strokec7 0\cf6 \strokec6 );\cf4 \strokec4 \
        cars\cf6 \strokec6 [\cf4 \strokec4 carID\cf6 \strokec6 ].\cf4 \strokec4 carAvailable \cf6 \strokec6 =\cf4 \strokec4  \cf5 \strokec5 false\cf6 \strokec6 ;\cf4 \strokec4  \cf2 \strokec2 // update car availability\cf4 \strokec4 \
        recordCnt\cf6 \strokec6 ++;\cf4 \strokec4 \
        \
\
        \cf2 \strokec2 // As number of car available has reduced by 1, return the 10ETH deposited by company during listing\cf4 \strokec4 \
        \cf5 \strokec5 uint\cf4 \strokec4  companyDeposit \cf6 \strokec6 =\cf4 \strokec4  \cf7 \strokec7 10\cf4 \strokec4  wei\cf6 \strokec6 ;\cf4 \strokec4 \
        contractBalance \cf6 \strokec6 =\cf4 \strokec4  contractBalance \cf6 \strokec6 -\cf4 \strokec4  companyDeposit\cf6 \strokec6 ;\cf4 \strokec4 \
        company\cf6 \strokec6 .\cf4 \strokec4 transfer\cf6 \strokec6 (\cf7 \strokec7 10\cf4 \strokec4  wei\cf6 \strokec6 );\cf4 \strokec4 \
    \cf6 \strokec6 \}\cf4 \strokec4 \
\
    \cf2 \strokec2 // Flow 6 & 7: return car and update state\cf4 \strokec4 \
    \cf2 \strokec2 // Company key in end date, then calculate total renting cost base on days rented.\cf4 \strokec4 \
    \cf2 \strokec2 // If the car is damaged, company will key in the amount to charge that will be added to total renting cost\cf4 \strokec4 \
    \cf2 \strokec2 // deduct total renting cost from deposit, any surplus return.\cf4 \strokec4 \
    \cf5 \strokec5 function\cf4 \strokec4  confirmReturn\cf6 \strokec6 (\cf5 \strokec5 string\cf4 \strokec4  \cf14 \strokec14 memory\cf4 \strokec4  carPlateNum\cf6 \strokec6 ,\cf4 \strokec4  \cf5 \strokec5 uint\cf4 \strokec4  damageCharge\cf6 \strokec6 ,\cf4 \strokec4  \cf5 \strokec5 uint\cf4 \strokec4  returnYear\cf6 \strokec6 ,\cf4 \strokec4  \cf5 \strokec5 uint\cf4 \strokec4  returnMonth\cf6 \strokec6 ,\cf4 \strokec4  \cf5 \strokec5 uint\cf4 \strokec4  returnDay\cf6 \strokec6 )\cf4 \strokec4  \
    \cf8 \strokec8 payable\cf4 \strokec4  \cf8 \strokec8 public\cf4 \strokec4  isCompany \cf6 \strokec6 \{\cf4 \strokec4 \
      \cf5 \strokec5 uint\cf4 \strokec4  recordIndex \cf6 \strokec6 =\cf4 \strokec4  \cf7 \strokec7 0\cf6 \strokec6 ;\cf4 \strokec4 \
      \cf5 \strokec5 uint\cf4 \strokec4  carIndex \cf6 \strokec6 =\cf4 \strokec4  \cf7 \strokec7 0\cf6 \strokec6 ;\cf4 \strokec4 \
      \cf5 \strokec5 bool\cf4 \strokec4  returnValid \cf6 \strokec6 =\cf4 \strokec4  \cf5 \strokec5 false\cf6 \strokec6 ;\cf4 \strokec4 \
      \
      \cf2 \strokec2 // Check records and car list to ensure car is rented by customer, and get the wallet address of the customer\cf4 \strokec4 \
      \cf13 \strokec13 for\cf4 \strokec4  \cf6 \strokec6 (\cf5 \strokec5 uint\cf4 \strokec4  i \cf6 \strokec6 =\cf4 \strokec4  recordCnt\cf6 \strokec6 ;\cf4 \strokec4  i \cf6 \strokec6 >\cf4 \strokec4  \cf7 \strokec7 0\cf6 \strokec6 ;\cf4 \strokec4  i\cf6 \strokec6 --)\cf4 \strokec4  \cf6 \strokec6 \{\cf4 \strokec4 \
        \cf12 \strokec12 if\cf4 \strokec4  \cf6 \strokec6 (\cf4 \strokec4  \cf10 \strokec10 keccak256\cf6 \strokec6 (\cf10 \strokec10 bytes\cf6 \strokec6 (\cf4 \strokec4 _toLower\cf6 \strokec6 (\cf4 \strokec4 records\cf6 \strokec6 [\cf4 \strokec4 i\cf6 \strokec6 -\cf7 \strokec7 1\cf6 \strokec6 ].\cf4 \strokec4 carPlate\cf6 \strokec6 )))\cf4 \strokec4  \cf6 \strokec6 ==\cf4 \strokec4  \cf10 \strokec10 keccak256\cf6 \strokec6 (\cf10 \strokec10 bytes\cf6 \strokec6 (\cf4 \strokec4 _toLower\cf6 \strokec6 (\cf4 \strokec4 carPlateNum\cf6 \strokec6 )))\cf4 \strokec4  \cf6 \strokec6 )\cf4 \strokec4  \cf6 \strokec6 \{\cf4 \strokec4 \
          recordIndex \cf6 \strokec6 =\cf4 \strokec4  i\cf6 \strokec6 -\cf7 \strokec7 1\cf6 \strokec6 ;\cf4 \strokec4 \
          returnValid \cf6 \strokec6 =\cf4 \strokec4  \cf5 \strokec5 true\cf6 \strokec6 ;\cf4 \strokec4 \
          \cf13 \strokec13 break\cf6 \strokec6 ;\cf4 \strokec4 \
        \cf6 \strokec6 \}\cf4 \strokec4 \
      \cf6 \strokec6 \}\cf4 \strokec4 \
      \cf10 \strokec10 require\cf6 \strokec6 (\cf4 \strokec4 returnValid\cf6 \strokec6 ,\cf4 \strokec4  \cf11 \strokec11 "This car is not rented by customer."\cf6 \strokec6 );\cf4 \strokec4 \
\
      \cf13 \strokec13 for\cf4 \strokec4  \cf6 \strokec6 (\cf5 \strokec5 uint\cf4 \strokec4  j \cf6 \strokec6 =\cf4 \strokec4  \cf7 \strokec7 0\cf6 \strokec6 ;\cf4 \strokec4  j \cf6 \strokec6 <\cf4 \strokec4  carCnt\cf6 \strokec6 ;\cf4 \strokec4  j\cf6 \strokec6 ++)\cf4 \strokec4  \cf6 \strokec6 \{\cf4 \strokec4 \
        \cf12 \strokec12 if\cf4 \strokec4  \cf6 \strokec6 (\cf4 \strokec4  \cf10 \strokec10 keccak256\cf6 \strokec6 (\cf10 \strokec10 bytes\cf6 \strokec6 (\cf4 \strokec4 _toLower\cf6 \strokec6 (\cf4 \strokec4 cars\cf6 \strokec6 [\cf4 \strokec4 j\cf6 \strokec6 ].\cf4 \strokec4 carPlate\cf6 \strokec6 )))\cf4 \strokec4  \cf6 \strokec6 ==\cf4 \strokec4  \cf10 \strokec10 keccak256\cf6 \strokec6 (\cf10 \strokec10 bytes\cf6 \strokec6 (\cf4 \strokec4 _toLower\cf6 \strokec6 (\cf4 \strokec4 carPlateNum\cf6 \strokec6 )))\cf4 \strokec4  \cf6 \strokec6 )\cf4 \strokec4  \cf6 \strokec6 \{\cf4 \strokec4 \
          carIndex \cf6 \strokec6 =\cf4 \strokec4  j\cf6 \strokec6 ;\cf4 \strokec4 \
          \cf13 \strokec13 break\cf6 \strokec6 ;\cf4 \strokec4 \
        \cf6 \strokec6 \}\cf4 \strokec4 \
      \cf6 \strokec6 \}\cf4 \strokec4 \
\
      \cf2 \strokec2 // Final check to make sure this is the right car we looking at. \cf4 \strokec4 \
      \cf10 \strokec10 require\cf6 \strokec6 (\cf4 \strokec4 cars\cf6 \strokec6 [\cf4 \strokec4 carIndex\cf6 \strokec6 ].\cf4 \strokec4 carAvailable \cf6 \strokec6 ==\cf4 \strokec4  \cf5 \strokec5 false\cf6 \strokec6 ,\cf4 \strokec4  \cf11 \strokec11 "The car is not rented by customer."\cf6 \strokec6 );\cf4 \strokec4 \
      \cf10 \strokec10 require\cf6 \strokec6 (\cf4 \strokec4 records\cf6 \strokec6 [\cf4 \strokec4 recordIndex\cf6 \strokec6 ].\cf4 \strokec4 carReturned \cf6 \strokec6 ==\cf4 \strokec4  \cf5 \strokec5 false\cf6 \strokec6 ,\cf4 \strokec4  \cf11 \strokec11 "This car has already been returned."\cf6 \strokec6 );\cf4 \strokec4 \
\
      \cf2 \strokec2 // Check date is entered correctly\cf4 \strokec4 \
      \cf10 \strokec10 require\cf6 \strokec6 (\cf4 \strokec4 returnDay \cf6 \strokec6 <=\cf4 \strokec4  \cf7 \strokec7 31\cf4 \strokec4  \cf6 \strokec6 &&\cf4 \strokec4  returnDay \cf6 \strokec6 >=\cf4 \strokec4  \cf7 \strokec7 1\cf6 \strokec6 ,\cf4 \strokec4  \cf11 \strokec11 "Check your day entered!"\cf6 \strokec6 );\cf4 \strokec4 \
      \cf10 \strokec10 require\cf6 \strokec6 (\cf4 \strokec4 returnMonth \cf6 \strokec6 <=\cf4 \strokec4  \cf7 \strokec7 12\cf4 \strokec4  \cf6 \strokec6 &&\cf4 \strokec4  returnMonth \cf6 \strokec6 >=\cf4 \strokec4  \cf7 \strokec7 1\cf6 \strokec6 ,\cf4 \strokec4  \cf11 \strokec11 "Check your month entered!"\cf6 \strokec6 );\cf4 \strokec4 \
      \cf10 \strokec10 require\cf6 \strokec6 (\cf4 \strokec4 returnYear \cf6 \strokec6 ==\cf4 \strokec4  getYear\cf6 \strokec6 (\cf10 \strokec10 block\cf6 \strokec6 .\cf4 \strokec4 timestamp\cf6 \strokec6 ),\cf4 \strokec4  \cf11 \strokec11 "Year of return should be the current year now which the car is returned."\cf6 \strokec6 );\cf4 \strokec4 \
\
      \cf2 \strokec2 // To confirm the return, the company need send in 10ETH which will be used to relist the car later\cf4 \strokec4 \
      \cf10 \strokec10 require\cf6 \strokec6 (\cf10 \strokec10 msg\cf6 \strokec6 .\cf4 \strokec4 value \cf6 \strokec6 ==\cf4 \strokec4  \cf7 \strokec7 10\cf4 \strokec4  wei\cf6 \strokec6 ,\cf4 \strokec4  \cf11 \strokec11 "The company needs to send in 10ETH to confirm the car return and relist it."\cf6 \strokec6 );\cf4 \strokec4 \
\
      \cf2 \strokec2 // To get the rental information\cf4 \strokec4 \
      \cf5 \strokec5 address\cf4 \strokec4  \cf8 \strokec8 payable\cf4 \strokec4  _walletAdd \cf6 \strokec6 =\cf4 \strokec4  \cf8 \strokec8 payable\cf6 \strokec6 (\cf4 \strokec4 records\cf6 \strokec6 [\cf4 \strokec4 recordIndex\cf6 \strokec6 ].\cf4 \strokec4 walletAdd\cf6 \strokec6 );\cf4 \strokec4 \
      \cf2 \strokec2 // uint _depositAmt = records[recordIndex].depositAmt;\cf4 \strokec4 \
      \cf5 \strokec5 uint\cf4 \strokec4  _numOfDays \cf6 \strokec6 =\cf4 \strokec4  records\cf6 \strokec6 [\cf4 \strokec4 recordIndex\cf6 \strokec6 ].\cf4 \strokec4 numOfDays\cf6 \strokec6 ;\cf4 \strokec4 \
      \cf2 \strokec2 // uint _startDate = records[recordIndex].startDate;\cf4 \strokec4 \
      \cf2 \strokec2 // uint _carType = cars[carIndex].carType;\cf4 \strokec4 \
      \cf5 \strokec5 uint\cf4 \strokec4  rent \cf6 \strokec6 =\cf4 \strokec4  \cf7 \strokec7 1\cf4 \strokec4  wei\cf6 \strokec6 ;\cf4 \strokec4 \
      \cf5 \strokec5 uint\cf4 \strokec4  additionalCharge \cf6 \strokec6 =\cf4 \strokec4  \cf7 \strokec7 1\cf4 \strokec4  wei\cf6 \strokec6 ;\cf4 \strokec4  \
      \cf5 \strokec5 uint\cf4 \strokec4  surplusAmt \cf6 \strokec6 =\cf4 \strokec4  \cf7 \strokec7 0\cf4 \strokec4  wei\cf6 \strokec6 ;\cf4 \strokec4 \
      \cf5 \strokec5 uint\cf4 \strokec4  lateFee \cf6 \strokec6 =\cf4 \strokec4  \cf7 \strokec7 0\cf4 \strokec4  wei\cf6 \strokec6 ;\cf4 \strokec4 \
      \cf2 \strokec2 // uint returnDate = block.timestamp;\cf4 \strokec4 \
      \cf5 \strokec5 uint\cf4 \strokec4  returnDate \cf6 \strokec6 =\cf4 \strokec4  timestampFromDate\cf6 \strokec6 (\cf4 \strokec4 returnYear\cf6 \strokec6 ,\cf4 \strokec4  returnMonth\cf6 \strokec6 ,\cf4 \strokec4  returnDay\cf6 \strokec6 );\cf4 \strokec4 \
\
      \cf2 \strokec2 // Update the return date in records\cf4 \strokec4 \
      records\cf6 \strokec6 [\cf4 \strokec4 recordIndex\cf6 \strokec6 ].\cf4 \strokec4 endDate \cf6 \strokec6 =\cf4 \strokec4  returnDate\cf6 \strokec6 ;\cf4 \strokec4 \
\
      \cf2 \strokec2 // check car type that was rented, default is 1 wei for 4-seater\cf4 \strokec4 \
      \cf12 \strokec12 if\cf4 \strokec4  \cf6 \strokec6 (\cf4 \strokec4 cars\cf6 \strokec6 [\cf4 \strokec4 carIndex\cf6 \strokec6 ].\cf4 \strokec4 carType \cf6 \strokec6 ==\cf4 \strokec4  \cf7 \strokec7 6\cf6 \strokec6 )\{\cf4 \strokec4 \
        rent \cf6 \strokec6 =\cf4 \strokec4  \cf7 \strokec7 2\cf4 \strokec4  wei\cf6 \strokec6 ;\cf4 \strokec4 \
      \cf6 \strokec6 \}\cf4 \strokec4  \
      \cf12 \strokec12 else\cf4 \strokec4  \cf12 \strokec12 if\cf4 \strokec4  \cf6 \strokec6 (\cf4 \strokec4 cars\cf6 \strokec6 [\cf4 \strokec4 carIndex\cf6 \strokec6 ].\cf4 \strokec4 carType \cf6 \strokec6 ==\cf4 \strokec4  \cf7 \strokec7 8\cf6 \strokec6 )\cf4 \strokec4  \cf6 \strokec6 \{\cf4 \strokec4 \
        rent \cf6 \strokec6 =\cf4 \strokec4  \cf7 \strokec7 3\cf4 \strokec4  wei\cf6 \strokec6 ;\cf4 \strokec4 \
      \cf6 \strokec6 \}\cf4 \strokec4 \
\
      \cf2 \strokec2 // Check if the car is returned late by calculating the days difference between startDate and endDate, and compare with numOfDays that user intended to rent.\cf4 \strokec4 \
      \cf5 \strokec5 uint\cf4 \strokec4  totalRentedDays \cf6 \strokec6 =\cf4 \strokec4  diffDays\cf6 \strokec6 (\cf4 \strokec4 records\cf6 \strokec6 [\cf4 \strokec4 recordIndex\cf6 \strokec6 ].\cf4 \strokec4 startDate\cf6 \strokec6 ,\cf4 \strokec4  returnDate\cf6 \strokec6 );\cf4 \strokec4 \
\
      \cf12 \strokec12 if\cf6 \strokec6 (\cf4 \strokec4 totalRentedDays \cf6 \strokec6 >\cf4 \strokec4  _numOfDays\cf6 \strokec6 )\cf4 \strokec4  \cf6 \strokec6 \{\cf4 \strokec4 \
        lateFee \cf6 \strokec6 =\cf4 \strokec4  rent \cf6 \strokec6 *\cf4 \strokec4  \cf6 \strokec6 (\cf4 \strokec4 totalRentedDays \cf6 \strokec6 -\cf4 \strokec4  _numOfDays\cf6 \strokec6 );\cf4 \strokec4  \cf2 \strokec2 //charge rent * number of days late\cf4 \strokec4 \
      \cf6 \strokec6 \}\cf4 \strokec4 \
\
      \cf2 \strokec2 // To calculate the total renting cost\cf4 \strokec4 \
      additionalCharge \cf6 \strokec6 =\cf4 \strokec4  additionalCharge \cf6 \strokec6 *\cf4 \strokec4  damageCharge\cf6 \strokec6 ;\cf4 \strokec4  \cf2 \strokec2 // convert to wei\cf4 \strokec4 \
      \cf5 \strokec5 uint\cf4 \strokec4  fee \cf6 \strokec6 =\cf4 \strokec4  _numOfDays \cf6 \strokec6 *\cf4 \strokec4  rent \cf6 \strokec6 +\cf4 \strokec4  additionalCharge \cf6 \strokec6 +\cf4 \strokec4  lateFee\cf6 \strokec6 ;\cf4 \strokec4 \
\
      \cf2 \strokec2 // update avail of the car by changing state to available\cf4 \strokec4 \
      cars\cf6 \strokec6 [\cf4 \strokec4 carIndex\cf6 \strokec6 ].\cf4 \strokec4 carAvailable \cf6 \strokec6 =\cf4 \strokec4  \cf5 \strokec5 true\cf6 \strokec6 ;\cf4 \strokec4 \
\
      \cf2 \strokec2 // Update record\cf4 \strokec4 \
      records\cf6 \strokec6 [\cf4 \strokec4 recordIndex\cf6 \strokec6 ].\cf4 \strokec4 carReturned \cf6 \strokec6 =\cf4 \strokec4  \cf5 \strokec5 true\cf6 \strokec6 ;\cf4 \strokec4 \
\
      \cf2 \strokec2 // Update the transfer of 10ETH from company account to relist the car. \cf4 \strokec4 \
      contractBalance \cf6 \strokec6 =\cf4 \strokec4  contractBalance \cf6 \strokec6 +\cf4 \strokec4  \cf7 \strokec7 10\cf4 \strokec4  wei\cf6 \strokec6 ;\cf4 \strokec4 \
\
      \cf2 \strokec2 // Check if deposit can cover the total fee\cf4 \strokec4 \
      \cf12 \strokec12 if\cf4 \strokec4  \cf6 \strokec6 (\cf4 \strokec4 records\cf6 \strokec6 [\cf4 \strokec4 recordIndex\cf6 \strokec6 ].\cf4 \strokec4 depositAmt \cf6 \strokec6 <=\cf4 \strokec4  fee\cf6 \strokec6 )\cf4 \strokec4  \cf6 \strokec6 \{\cf4 \strokec4 \
        \cf2 \strokec2 // log the deficit that we require from the user\cf4 \strokec4 \
        records\cf6 \strokec6 [\cf4 \strokec4 recordIndex\cf6 \strokec6 ].\cf4 \strokec4 outstandingFee \cf6 \strokec6 =\cf4 \strokec4  fee \cf6 \strokec6 -\cf4 \strokec4  records\cf6 \strokec6 [\cf4 \strokec4 recordIndex\cf6 \strokec6 ].\cf4 \strokec4 depositAmt\cf6 \strokec6 ;\cf4 \strokec4 \
\
        \cf2 \strokec2 // No surplus and we take all the deposit \cf4 \strokec4 \
        \cf2 \strokec2 // surplusAmt = 0 wei;\cf4 \strokec4 \
        contractBalance \cf6 \strokec6 =\cf4 \strokec4  contractBalance \cf6 \strokec6 -\cf4 \strokec4  records\cf6 \strokec6 [\cf4 \strokec4 recordIndex\cf6 \strokec6 ].\cf4 \strokec4 depositAmt\cf6 \strokec6 ;\cf4 \strokec4  \
        company\cf6 \strokec6 .\cf4 \strokec4 transfer\cf6 \strokec6 (\cf4 \strokec4 records\cf6 \strokec6 [\cf4 \strokec4 recordIndex\cf6 \strokec6 ].\cf4 \strokec4 depositAmt\cf6 \strokec6 );\cf4 \strokec4 \
      \cf6 \strokec6 \}\cf4 \strokec4 \
      \cf12 \strokec12 else\cf4 \strokec4  \cf6 \strokec6 \{\cf4 \strokec4  \
        surplusAmt \cf6 \strokec6 =\cf4 \strokec4  records\cf6 \strokec6 [\cf4 \strokec4 recordIndex\cf6 \strokec6 ].\cf4 \strokec4 depositAmt \cf6 \strokec6 -\cf4 \strokec4  fee\cf6 \strokec6 ;\cf4 \strokec4 \
        \
        \cf2 \strokec2 // update contractbalance\cf4 \strokec4 \
        contractBalance \cf6 \strokec6 =\cf4 \strokec4  contractBalance \cf6 \strokec6 -\cf4 \strokec4  surplusAmt\cf6 \strokec6 ;\cf4 \strokec4 \
        contractBalance \cf6 \strokec6 =\cf4 \strokec4  contractBalance \cf6 \strokec6 -\cf4 \strokec4  fee\cf6 \strokec6 ;\cf4 \strokec4 \
\
        \cf2 \strokec2 // Transfer surplus to customer\cf4 \strokec4 \
        _walletAdd\cf6 \strokec6 .\cf4 \strokec4 transfer\cf6 \strokec6 (\cf4 \strokec4 surplusAmt\cf6 \strokec6 );\cf4 \strokec4 \
\
        \cf2 \strokec2 // Transfer fee earnings to company\cf4 \strokec4 \
        company\cf6 \strokec6 .\cf4 \strokec4 transfer\cf6 \strokec6 (\cf4 \strokec4 fee\cf6 \strokec6 );\cf4 \strokec4 \
      \cf6 \strokec6 \}\cf4 \strokec4 \
\
      \cf2 \strokec2 // Ensure no overflow for the surplus, definitely will be between 0 and a value less than the deposit\cf4 \strokec4 \
      \cf10 \strokec10 require\cf6 \strokec6 (\cf4 \strokec4 surplusAmt \cf6 \strokec6 >=\cf4 \strokec4  \cf7 \strokec7 0\cf4 \strokec4  \cf6 \strokec6 &&\cf4 \strokec4  surplusAmt \cf6 \strokec6 <\cf4 \strokec4  records\cf6 \strokec6 [\cf4 \strokec4 recordIndex\cf6 \strokec6 ].\cf4 \strokec4 depositAmt\cf6 \strokec6 ,\cf4 \strokec4  \cf11 \strokec11 "Customer's deposit not enough to cover the additional damage charge, topup required!"\cf6 \strokec6 );\cf4 \strokec4 \
    \cf6 \strokec6 \}\cf4 \strokec4 \
\
\
    \cf2 \strokec2 // Pay outstanding fees if needed\cf4 \strokec4 \
    \cf5 \strokec5 function\cf4 \strokec4  ChecknPayOutstanding\cf6 \strokec6 (\cf5 \strokec5 address\cf4 \strokec4  walletAddress\cf6 \strokec6 )\cf4 \strokec4  \
    \cf8 \strokec8 payable\cf4 \strokec4  \cf8 \strokec8 public\cf4 \strokec4  \cf6 \strokec6 \{\cf4 \strokec4 \
      \cf10 \strokec10 require\cf6 \strokec6 (\cf10 \strokec10 msg\cf6 \strokec6 .\cf4 \strokec4 sender \cf6 \strokec6 ==\cf4 \strokec4  walletAddress\cf6 \strokec6 ,\cf4 \strokec4  \cf11 \strokec11 "You need to be the owner of this wallet address to pay outstanding fees."\cf6 \strokec6 );\cf4 \strokec4 \
      \cf5 \strokec5 address\cf4 \strokec4  \cf8 \strokec8 payable\cf4 \strokec4  _walletAdd \cf6 \strokec6 =\cf4 \strokec4  \cf8 \strokec8 payable\cf6 \strokec6 (\cf4 \strokec4 walletAddress\cf6 \strokec6 );\cf4 \strokec4 \
\
      \cf5 \strokec5 bool\cf4 \strokec4  needPay \cf6 \strokec6 =\cf4 \strokec4  \cf5 \strokec5 true\cf6 \strokec6 ;\cf4 \strokec4 \
      \cf5 \strokec5 uint\cf4 \strokec4  ind \cf6 \strokec6 =\cf4 \strokec4  \cf7 \strokec7 0\cf6 \strokec6 ;\cf4 \strokec4 \
      \cf5 \strokec5 uint\cf4 \strokec4  surplus \cf6 \strokec6 =\cf4 \strokec4  \cf7 \strokec7 0\cf6 \strokec6 ;\cf4 \strokec4 \
\
      \cf13 \strokec13 for\cf4 \strokec4  \cf6 \strokec6 (\cf5 \strokec5 uint\cf4 \strokec4  i \cf6 \strokec6 =\cf4 \strokec4  recordCnt\cf6 \strokec6 ;\cf4 \strokec4  i \cf6 \strokec6 >\cf4 \strokec4  \cf7 \strokec7 0\cf6 \strokec6 ;\cf4 \strokec4  i\cf6 \strokec6 --)\cf4 \strokec4  \cf6 \strokec6 \{\cf4 \strokec4 \
        \cf12 \strokec12 if\cf4 \strokec4  \cf6 \strokec6 (\cf4 \strokec4 records\cf6 \strokec6 [\cf4 \strokec4 i\cf6 \strokec6 -\cf7 \strokec7 1\cf6 \strokec6 ].\cf4 \strokec4 walletAdd \cf6 \strokec6 ==\cf4 \strokec4  walletAddress \cf6 \strokec6 &&\cf4 \strokec4  records\cf6 \strokec6 [\cf4 \strokec4 i\cf6 \strokec6 -\cf7 \strokec7 1\cf6 \strokec6 ].\cf4 \strokec4 outstandingFee \cf6 \strokec6 ==\cf4 \strokec4  \cf7 \strokec7 0\cf6 \strokec6 )\cf4 \strokec4  \cf6 \strokec6 \{\cf4 \strokec4 \
          \cf2 \strokec2 // If the latest record available for this wallet address shows no outstanding fee, renter is allowed to rent \cf4 \strokec4 \
          needPay \cf6 \strokec6 =\cf4 \strokec4  \cf5 \strokec5 false\cf6 \strokec6 ;\cf4 \strokec4 \
          \cf13 \strokec13 break\cf6 \strokec6 ;\cf4 \strokec4 \
        \cf6 \strokec6 \}\cf4 \strokec4 \
        \cf12 \strokec12 else\cf4 \strokec4  \cf12 \strokec12 if\cf4 \strokec4  \cf6 \strokec6 (\cf4 \strokec4 records\cf6 \strokec6 [\cf4 \strokec4 i\cf6 \strokec6 -\cf7 \strokec7 1\cf6 \strokec6 ].\cf4 \strokec4 walletAdd \cf6 \strokec6 ==\cf4 \strokec4  walletAddress \cf6 \strokec6 &&\cf4 \strokec4  records\cf6 \strokec6 [\cf4 \strokec4 i\cf6 \strokec6 -\cf7 \strokec7 1\cf6 \strokec6 ].\cf4 \strokec4 outstandingFee \cf6 \strokec6 !=\cf4 \strokec4  \cf7 \strokec7 0\cf6 \strokec6 )\cf4 \strokec4  \cf6 \strokec6 \{\cf4 \strokec4 \
          \cf2 \strokec2 // found the record index where this wallet address has an outstanding fine\cf4 \strokec4 \
          ind \cf6 \strokec6 =\cf4 \strokec4  i\cf6 \strokec6 -\cf7 \strokec7 1\cf6 \strokec6 ;\cf4 \strokec4 \
        \cf6 \strokec6 \}\cf4 \strokec4 \
      \cf6 \strokec6 \}\cf4 \strokec4 \
\
      \cf10 \strokec10 require\cf6 \strokec6 (\cf4 \strokec4 needPay \cf6 \strokec6 ==\cf4 \strokec4  \cf5 \strokec5 true\cf6 \strokec6 ,\cf4 \strokec4  \cf11 \strokec11 "You have no outstanding fees to pay! Go ahead and rent a car!"\cf6 \strokec6 );\cf4 \strokec4 \
\
      \cf12 \strokec12 if\cf4 \strokec4  \cf6 \strokec6 (\cf4 \strokec4 records\cf6 \strokec6 [\cf4 \strokec4 ind\cf6 \strokec6 ].\cf4 \strokec4 outstandingFee \cf6 \strokec6 >\cf4 \strokec4  \cf7 \strokec7 0\cf4 \strokec4  \cf6 \strokec6 &&\cf4 \strokec4  records\cf6 \strokec6 [\cf4 \strokec4 ind\cf6 \strokec6 ].\cf4 \strokec4 outstandingFee \cf6 \strokec6 <\cf4 \strokec4  \cf7 \strokec7 10\cf6 \strokec6 )\cf4 \strokec4  \cf6 \strokec6 \{\cf4 \strokec4 \
        \cf10 \strokec10 require\cf6 \strokec6 (\cf10 \strokec10 msg\cf6 \strokec6 .\cf4 \strokec4 value \cf6 \strokec6 >=\cf4 \strokec4  \cf7 \strokec7 10\cf4 \strokec4  wei\cf6 \strokec6 ,\cf4 \strokec4  \cf11 \strokec11 "Please send at least 10 ETH to pay your outstanding fine. Surplus will be returned to you."\cf6 \strokec6 );\cf4 \strokec4 \
        surplus \cf6 \strokec6 =\cf4 \strokec4  \cf10 \strokec10 msg\cf6 \strokec6 .\cf4 \strokec4 value \cf6 \strokec6 -\cf4 \strokec4  records\cf6 \strokec6 [\cf4 \strokec4 ind\cf6 \strokec6 ].\cf4 \strokec4 outstandingFee\cf6 \strokec6 ;\cf4 \strokec4 \
        records\cf6 \strokec6 [\cf4 \strokec4 ind\cf6 \strokec6 ].\cf4 \strokec4 outstandingFee \cf6 \strokec6 =\cf4 \strokec4  \cf7 \strokec7 0\cf6 \strokec6 ;\cf4 \strokec4 \
        company\cf6 \strokec6 .\cf4 \strokec4 transfer\cf6 \strokec6 (\cf4 \strokec4 records\cf6 \strokec6 [\cf4 \strokec4 ind\cf6 \strokec6 ].\cf4 \strokec4 outstandingFee\cf6 \strokec6 );\cf4 \strokec4  \
        _walletAdd\cf6 \strokec6 .\cf4 \strokec4 transfer\cf6 \strokec6 (\cf4 \strokec4 surplus\cf6 \strokec6 );\cf4 \strokec4 \
      \cf6 \strokec6 \}\cf4 \strokec4 \
\
      \cf12 \strokec12 if\cf4 \strokec4  \cf6 \strokec6 (\cf4 \strokec4 records\cf6 \strokec6 [\cf4 \strokec4 ind\cf6 \strokec6 ].\cf4 \strokec4 outstandingFee \cf6 \strokec6 >=\cf4 \strokec4  \cf7 \strokec7 10\cf4 \strokec4   \cf6 \strokec6 &&\cf4 \strokec4  records\cf6 \strokec6 [\cf4 \strokec4 ind\cf6 \strokec6 ].\cf4 \strokec4 outstandingFee \cf6 \strokec6 <\cf4 \strokec4  \cf7 \strokec7 100\cf6 \strokec6 )\cf4 \strokec4  \cf6 \strokec6 \{\cf4 \strokec4 \
        \cf10 \strokec10 require\cf6 \strokec6 (\cf10 \strokec10 msg\cf6 \strokec6 .\cf4 \strokec4 value \cf6 \strokec6 >=\cf4 \strokec4  \cf7 \strokec7 100\cf4 \strokec4  wei\cf6 \strokec6 ,\cf4 \strokec4  \cf11 \strokec11 "Please send at least 100 ETH to pay your outstanding fine. Surplus will be returned to you."\cf6 \strokec6 );\cf4 \strokec4 \
        surplus \cf6 \strokec6 =\cf4 \strokec4  \cf10 \strokec10 msg\cf6 \strokec6 .\cf4 \strokec4 value \cf6 \strokec6 -\cf4 \strokec4  records\cf6 \strokec6 [\cf4 \strokec4 ind\cf6 \strokec6 ].\cf4 \strokec4 outstandingFee\cf6 \strokec6 ;\cf4 \strokec4 \
        records\cf6 \strokec6 [\cf4 \strokec4 ind\cf6 \strokec6 ].\cf4 \strokec4 outstandingFee \cf6 \strokec6 =\cf4 \strokec4  \cf7 \strokec7 0\cf6 \strokec6 ;\cf4 \strokec4 \
        company\cf6 \strokec6 .\cf4 \strokec4 transfer\cf6 \strokec6 (\cf4 \strokec4 records\cf6 \strokec6 [\cf4 \strokec4 ind\cf6 \strokec6 ].\cf4 \strokec4 outstandingFee\cf6 \strokec6 );\cf4 \strokec4  \
        _walletAdd\cf6 \strokec6 .\cf4 \strokec4 transfer\cf6 \strokec6 (\cf4 \strokec4 surplus\cf6 \strokec6 );\cf4 \strokec4 \
      \cf6 \strokec6 \}\cf4 \strokec4 \
\
      \cf12 \strokec12 if\cf4 \strokec4  \cf6 \strokec6 (\cf4 \strokec4 records\cf6 \strokec6 [\cf4 \strokec4 ind\cf6 \strokec6 ].\cf4 \strokec4 outstandingFee \cf6 \strokec6 >=\cf4 \strokec4  \cf7 \strokec7 100\cf6 \strokec6 )\cf4 \strokec4  \cf6 \strokec6 \{\cf4 \strokec4 \
        needPay \cf6 \strokec6 =\cf4 \strokec4  \cf5 \strokec5 false\cf6 \strokec6 ;\cf4 \strokec4 \
        \cf10 \strokec10 require\cf6 \strokec6 (\cf4 \strokec4 needPay \cf6 \strokec6 ==\cf4 \strokec4  \cf5 \strokec5 true\cf6 \strokec6 ,\cf4 \strokec4  \cf11 \strokec11 "Your outstanding fee is too large and thus have been blacklisted from rental. Please contact a representative from ABC Rental Company for settlement."\cf6 \strokec6 );\cf4 \strokec4 \
      \cf6 \strokec6 \}\cf4 \strokec4 \
\
      \cf10 \strokec10 require\cf6 \strokec6 (\cf4 \strokec4 recordCnt \cf6 \strokec6 >\cf4 \strokec4  \cf7 \strokec7 0\cf6 \strokec6 ,\cf4 \strokec4  \cf11 \strokec11 "There is no outstanding associated thus far!"\cf6 \strokec6 );\cf4 \strokec4 \
    \cf6 \strokec6 \}\cf4 \strokec4 \
\
\
  \cf2 \strokec2 /********************************************************************************************************/\cf4 \strokec4 \
  \cf2 \strokec2 /*                                          Helper Functions                                            */\cf4 \strokec4 \
  \cf2 \strokec2 /********************************************************************************************************/\cf4 \strokec4 \
\
    \cf2 \strokec2 // Convert strings to lowercase \cf4 \strokec4 \
    \cf5 \strokec5 function\cf4 \strokec4  _toLower\cf6 \strokec6 (\cf5 \strokec5 string\cf4 \strokec4  \cf14 \strokec14 memory\cf4 \strokec4  str\cf6 \strokec6 )\cf4 \strokec4  \cf8 \strokec8 internal\cf4 \strokec4  \cf8 \strokec8 pure\cf4 \strokec4  \cf15 \strokec15 returns\cf4 \strokec4  \cf6 \strokec6 (\cf5 \strokec5 string\cf4 \strokec4  \cf14 \strokec14 memory\cf6 \strokec6 )\cf4 \strokec4  \cf6 \strokec6 \{\cf4 \strokec4 \
        \cf10 \strokec10 bytes\cf4 \strokec4  \cf14 \strokec14 memory\cf4 \strokec4  bStr \cf6 \strokec6 =\cf4 \strokec4  \cf10 \strokec10 bytes\cf6 \strokec6 (\cf4 \strokec4 str\cf6 \strokec6 );\cf4 \strokec4 \
        \cf10 \strokec10 bytes\cf4 \strokec4  \cf14 \strokec14 memory\cf4 \strokec4  bLower \cf6 \strokec6 =\cf4 \strokec4  \cf5 \strokec5 new\cf4 \strokec4  \cf10 \strokec10 bytes\cf6 \strokec6 (\cf4 \strokec4 bStr\cf6 \strokec6 .\cf4 \strokec4 length\cf6 \strokec6 );\cf4 \strokec4 \
        \cf13 \strokec13 for\cf4 \strokec4  \cf6 \strokec6 (\cf5 \strokec5 uint\cf4 \strokec4  i \cf6 \strokec6 =\cf4 \strokec4  \cf7 \strokec7 0\cf6 \strokec6 ;\cf4 \strokec4  i \cf6 \strokec6 <\cf4 \strokec4  bStr\cf6 \strokec6 .\cf4 \strokec4 length\cf6 \strokec6 ;\cf4 \strokec4  i\cf6 \strokec6 ++)\cf4 \strokec4  \cf6 \strokec6 \{\cf4 \strokec4 \
            \cf2 \strokec2 // Uppercase character...\cf4 \strokec4 \
            \cf12 \strokec12 if\cf4 \strokec4  \cf6 \strokec6 ((\cf5 \strokec5 uint8\cf6 \strokec6 (\cf4 \strokec4 bStr\cf6 \strokec6 [\cf4 \strokec4 i\cf6 \strokec6 ])\cf4 \strokec4  \cf6 \strokec6 >=\cf4 \strokec4  \cf7 \strokec7 65\cf6 \strokec6 )\cf4 \strokec4  \cf6 \strokec6 &&\cf4 \strokec4  \cf6 \strokec6 (\cf5 \strokec5 uint8\cf6 \strokec6 (\cf4 \strokec4 bStr\cf6 \strokec6 [\cf4 \strokec4 i\cf6 \strokec6 ])\cf4 \strokec4  \cf6 \strokec6 <=\cf4 \strokec4  \cf7 \strokec7 90\cf6 \strokec6 ))\cf4 \strokec4  \cf6 \strokec6 \{\cf4 \strokec4 \
                \cf2 \strokec2 // So we add 32 to make it lowercase\cf4 \strokec4 \
                bLower\cf6 \strokec6 [\cf4 \strokec4 i\cf6 \strokec6 ]\cf4 \strokec4  \cf6 \strokec6 =\cf4 \strokec4  \cf5 \strokec5 bytes1\cf6 \strokec6 (\cf5 \strokec5 uint8\cf6 \strokec6 (\cf4 \strokec4 bStr\cf6 \strokec6 [\cf4 \strokec4 i\cf6 \strokec6 ])\cf4 \strokec4  \cf6 \strokec6 +\cf4 \strokec4  \cf7 \strokec7 32\cf6 \strokec6 );\cf4 \strokec4 \
            \cf6 \strokec6 \}\cf4 \strokec4  \cf12 \strokec12 else\cf4 \strokec4  \cf6 \strokec6 \{\cf4 \strokec4 \
                bLower\cf6 \strokec6 [\cf4 \strokec4 i\cf6 \strokec6 ]\cf4 \strokec4  \cf6 \strokec6 =\cf4 \strokec4  bStr\cf6 \strokec6 [\cf4 \strokec4 i\cf6 \strokec6 ];\cf4 \strokec4 \
            \cf6 \strokec6 \}\cf4 \strokec4 \
        \cf6 \strokec6 \}\cf4 \strokec4 \
        \cf15 \strokec15 return\cf4 \strokec4  \cf5 \strokec5 string\cf6 \strokec6 (\cf4 \strokec4 bLower\cf6 \strokec6 );\cf4 \strokec4 \
    \cf6 \strokec6 \}\cf4 \strokec4 \
\
\
    \cf2 \strokec2 // Datetime function from BokkyPooBahs: https://github.com/bokkypoobah/BokkyPooBahsDateTimeLibrary/blob/master/contracts/BokkyPooBahsDateTimeLibrary.sol\cf4 \strokec4 \
    \cf2 \strokec2 // uint SECONDS_PER_DAY = 24 * 60 * 60;\cf4 \strokec4 \
    \cf5 \strokec5 function\cf4 \strokec4  _daysFromDate\cf6 \strokec6 (\cf5 \strokec5 uint\cf4 \strokec4  year\cf6 \strokec6 ,\cf4 \strokec4  \cf5 \strokec5 uint\cf4 \strokec4  month\cf6 \strokec6 ,\cf4 \strokec4  \cf5 \strokec5 uint\cf4 \strokec4  day\cf6 \strokec6 )\cf4 \strokec4  \cf8 \strokec8 internal\cf4 \strokec4  \cf8 \strokec8 pure\cf4 \strokec4  \cf15 \strokec15 returns\cf4 \strokec4  \cf6 \strokec6 (\cf5 \strokec5 uint\cf4 \strokec4  _days\cf6 \strokec6 )\cf4 \strokec4  \cf6 \strokec6 \{\cf4 \strokec4 \
        \cf5 \strokec5 int\cf4 \strokec4  OFFSET19700101 \cf6 \strokec6 =\cf4 \strokec4  \cf7 \strokec7 2440588\cf6 \strokec6 ;\cf4 \strokec4 \
        \cf10 \strokec10 require\cf6 \strokec6 (\cf4 \strokec4 year \cf6 \strokec6 >=\cf4 \strokec4  \cf7 \strokec7 1970\cf6 \strokec6 );\cf4 \strokec4 \
        \cf5 \strokec5 int\cf4 \strokec4  _year \cf6 \strokec6 =\cf4 \strokec4  \cf5 \strokec5 int\cf6 \strokec6 (\cf4 \strokec4 year\cf6 \strokec6 );\cf4 \strokec4 \
        \cf5 \strokec5 int\cf4 \strokec4  _month \cf6 \strokec6 =\cf4 \strokec4  \cf5 \strokec5 int\cf6 \strokec6 (\cf4 \strokec4 month\cf6 \strokec6 );\cf4 \strokec4 \
        \cf5 \strokec5 int\cf4 \strokec4  _day \cf6 \strokec6 =\cf4 \strokec4  \cf5 \strokec5 int\cf6 \strokec6 (\cf4 \strokec4 day\cf6 \strokec6 );\cf4 \strokec4 \
\
        \cf5 \strokec5 int\cf4 \strokec4  __days \cf6 \strokec6 =\cf4 \strokec4  _day\
          \cf6 \strokec6 -\cf4 \strokec4  \cf7 \strokec7 32075\cf4 \strokec4 \
          \cf6 \strokec6 +\cf4 \strokec4  \cf7 \strokec7 1461\cf4 \strokec4  \cf6 \strokec6 *\cf4 \strokec4  \cf6 \strokec6 (\cf4 \strokec4 _year \cf6 \strokec6 +\cf4 \strokec4  \cf7 \strokec7 4800\cf4 \strokec4  \cf6 \strokec6 +\cf4 \strokec4  \cf6 \strokec6 (\cf4 \strokec4 _month \cf6 \strokec6 -\cf4 \strokec4  \cf7 \strokec7 14\cf6 \strokec6 )\cf4 \strokec4  \cf6 \strokec6 /\cf4 \strokec4  \cf7 \strokec7 12\cf6 \strokec6 )\cf4 \strokec4  \cf6 \strokec6 /\cf4 \strokec4  \cf7 \strokec7 4\cf4 \strokec4 \
          \cf6 \strokec6 +\cf4 \strokec4  \cf7 \strokec7 367\cf4 \strokec4  \cf6 \strokec6 *\cf4 \strokec4  \cf6 \strokec6 (\cf4 \strokec4 _month \cf6 \strokec6 -\cf4 \strokec4  \cf7 \strokec7 2\cf4 \strokec4  \cf6 \strokec6 -\cf4 \strokec4  \cf6 \strokec6 (\cf4 \strokec4 _month \cf6 \strokec6 -\cf4 \strokec4  \cf7 \strokec7 14\cf6 \strokec6 )\cf4 \strokec4  \cf6 \strokec6 /\cf4 \strokec4  \cf7 \strokec7 12\cf4 \strokec4  \cf6 \strokec6 *\cf4 \strokec4  \cf7 \strokec7 12\cf6 \strokec6 )\cf4 \strokec4  \cf6 \strokec6 /\cf4 \strokec4  \cf7 \strokec7 12\cf4 \strokec4 \
          \cf6 \strokec6 -\cf4 \strokec4  \cf7 \strokec7 3\cf4 \strokec4  \cf6 \strokec6 *\cf4 \strokec4  \cf6 \strokec6 ((\cf4 \strokec4 _year \cf6 \strokec6 +\cf4 \strokec4  \cf7 \strokec7 4900\cf4 \strokec4  \cf6 \strokec6 +\cf4 \strokec4  \cf6 \strokec6 (\cf4 \strokec4 _month \cf6 \strokec6 -\cf4 \strokec4  \cf7 \strokec7 14\cf6 \strokec6 )\cf4 \strokec4  \cf6 \strokec6 /\cf4 \strokec4  \cf7 \strokec7 12\cf6 \strokec6 )\cf4 \strokec4  \cf6 \strokec6 /\cf4 \strokec4  \cf7 \strokec7 100\cf6 \strokec6 )\cf4 \strokec4  \cf6 \strokec6 /\cf4 \strokec4  \cf7 \strokec7 4\cf4 \strokec4 \
          \cf6 \strokec6 -\cf4 \strokec4  OFFSET19700101\cf6 \strokec6 ;\cf4 \strokec4 \
\
        _days \cf6 \strokec6 =\cf4 \strokec4  \cf5 \strokec5 uint\cf6 \strokec6 (\cf4 \strokec4 __days\cf6 \strokec6 );\cf4 \strokec4 \
    \cf6 \strokec6 \}\cf4 \strokec4 \
    \cf5 \strokec5 function\cf4 \strokec4  _daysToDate\cf6 \strokec6 (\cf5 \strokec5 uint\cf4 \strokec4  _days\cf6 \strokec6 )\cf4 \strokec4  \cf8 \strokec8 internal\cf4 \strokec4  \cf8 \strokec8 pure\cf4 \strokec4  \cf15 \strokec15 returns\cf4 \strokec4  \cf6 \strokec6 (\cf5 \strokec5 uint\cf4 \strokec4  year\cf6 \strokec6 ,\cf4 \strokec4  \cf5 \strokec5 uint\cf4 \strokec4  month\cf6 \strokec6 ,\cf4 \strokec4  \cf5 \strokec5 uint\cf4 \strokec4  day\cf6 \strokec6 )\cf4 \strokec4  \cf6 \strokec6 \{\cf4 \strokec4 \
        \cf5 \strokec5 int\cf4 \strokec4  __days \cf6 \strokec6 =\cf4 \strokec4  \cf5 \strokec5 int\cf6 \strokec6 (\cf4 \strokec4 _days\cf6 \strokec6 );\cf4 \strokec4 \
        \cf5 \strokec5 int\cf4 \strokec4  OFFSET19700101 \cf6 \strokec6 =\cf4 \strokec4  \cf7 \strokec7 2440588\cf6 \strokec6 ;\cf4 \strokec4 \
\
        \cf5 \strokec5 int\cf4 \strokec4  L \cf6 \strokec6 =\cf4 \strokec4  __days \cf6 \strokec6 +\cf4 \strokec4  \cf7 \strokec7 68569\cf4 \strokec4  \cf6 \strokec6 +\cf4 \strokec4  OFFSET19700101\cf6 \strokec6 ;\cf4 \strokec4 \
        \cf5 \strokec5 int\cf4 \strokec4  N \cf6 \strokec6 =\cf4 \strokec4  \cf7 \strokec7 4\cf4 \strokec4  \cf6 \strokec6 *\cf4 \strokec4  L \cf6 \strokec6 /\cf4 \strokec4  \cf7 \strokec7 146097\cf6 \strokec6 ;\cf4 \strokec4 \
        L \cf6 \strokec6 =\cf4 \strokec4  L \cf6 \strokec6 -\cf4 \strokec4  \cf6 \strokec6 (\cf7 \strokec7 146097\cf4 \strokec4  \cf6 \strokec6 *\cf4 \strokec4  N \cf6 \strokec6 +\cf4 \strokec4  \cf7 \strokec7 3\cf6 \strokec6 )\cf4 \strokec4  \cf6 \strokec6 /\cf4 \strokec4  \cf7 \strokec7 4\cf6 \strokec6 ;\cf4 \strokec4 \
        \cf5 \strokec5 int\cf4 \strokec4  _year \cf6 \strokec6 =\cf4 \strokec4  \cf7 \strokec7 4000\cf4 \strokec4  \cf6 \strokec6 *\cf4 \strokec4  \cf6 \strokec6 (\cf4 \strokec4 L \cf6 \strokec6 +\cf4 \strokec4  \cf7 \strokec7 1\cf6 \strokec6 )\cf4 \strokec4  \cf6 \strokec6 /\cf4 \strokec4  \cf7 \strokec7 1461001\cf6 \strokec6 ;\cf4 \strokec4 \
        L \cf6 \strokec6 =\cf4 \strokec4  L \cf6 \strokec6 -\cf4 \strokec4  \cf7 \strokec7 1461\cf4 \strokec4  \cf6 \strokec6 *\cf4 \strokec4  _year \cf6 \strokec6 /\cf4 \strokec4  \cf7 \strokec7 4\cf4 \strokec4  \cf6 \strokec6 +\cf4 \strokec4  \cf7 \strokec7 31\cf6 \strokec6 ;\cf4 \strokec4 \
        \cf5 \strokec5 int\cf4 \strokec4  _month \cf6 \strokec6 =\cf4 \strokec4  \cf7 \strokec7 80\cf4 \strokec4  \cf6 \strokec6 *\cf4 \strokec4  L \cf6 \strokec6 /\cf4 \strokec4  \cf7 \strokec7 2447\cf6 \strokec6 ;\cf4 \strokec4 \
        \cf5 \strokec5 int\cf4 \strokec4  _day \cf6 \strokec6 =\cf4 \strokec4  L \cf6 \strokec6 -\cf4 \strokec4  \cf7 \strokec7 2447\cf4 \strokec4  \cf6 \strokec6 *\cf4 \strokec4  _month \cf6 \strokec6 /\cf4 \strokec4  \cf7 \strokec7 80\cf6 \strokec6 ;\cf4 \strokec4 \
        L \cf6 \strokec6 =\cf4 \strokec4  _month \cf6 \strokec6 /\cf4 \strokec4  \cf7 \strokec7 11\cf6 \strokec6 ;\cf4 \strokec4 \
        _month \cf6 \strokec6 =\cf4 \strokec4  _month \cf6 \strokec6 +\cf4 \strokec4  \cf7 \strokec7 2\cf4 \strokec4  \cf6 \strokec6 -\cf4 \strokec4  \cf7 \strokec7 12\cf4 \strokec4  \cf6 \strokec6 *\cf4 \strokec4  L\cf6 \strokec6 ;\cf4 \strokec4 \
        _year \cf6 \strokec6 =\cf4 \strokec4  \cf7 \strokec7 100\cf4 \strokec4  \cf6 \strokec6 *\cf4 \strokec4  \cf6 \strokec6 (\cf4 \strokec4 N \cf6 \strokec6 -\cf4 \strokec4  \cf7 \strokec7 49\cf6 \strokec6 )\cf4 \strokec4  \cf6 \strokec6 +\cf4 \strokec4  _year \cf6 \strokec6 +\cf4 \strokec4  L\cf6 \strokec6 ;\cf4 \strokec4 \
\
        year \cf6 \strokec6 =\cf4 \strokec4  \cf5 \strokec5 uint\cf6 \strokec6 (\cf4 \strokec4 _year\cf6 \strokec6 );\cf4 \strokec4 \
        month \cf6 \strokec6 =\cf4 \strokec4  \cf5 \strokec5 uint\cf6 \strokec6 (\cf4 \strokec4 _month\cf6 \strokec6 );\cf4 \strokec4 \
        day \cf6 \strokec6 =\cf4 \strokec4  \cf5 \strokec5 uint\cf6 \strokec6 (\cf4 \strokec4 _day\cf6 \strokec6 );\cf4 \strokec4 \
    \cf6 \strokec6 \}\cf4 \strokec4 \
    \
    \cf5 \strokec5 function\cf4 \strokec4  timestampFromDate\cf6 \strokec6 (\cf5 \strokec5 uint\cf4 \strokec4  year\cf6 \strokec6 ,\cf4 \strokec4  \cf5 \strokec5 uint\cf4 \strokec4  month\cf6 \strokec6 ,\cf4 \strokec4  \cf5 \strokec5 uint\cf4 \strokec4  day\cf6 \strokec6 )\cf4 \strokec4  \cf8 \strokec8 internal\cf4 \strokec4  \cf8 \strokec8 pure\cf4 \strokec4  \cf15 \strokec15 returns\cf4 \strokec4  \cf6 \strokec6 (\cf5 \strokec5 uint\cf4 \strokec4  timestamp\cf6 \strokec6 )\cf4 \strokec4  \cf6 \strokec6 \{\cf4 \strokec4 \
        \cf5 \strokec5 uint\cf4 \strokec4  SECONDS_PER_DAY \cf6 \strokec6 =\cf4 \strokec4  \cf7 \strokec7 24\cf4 \strokec4  \cf6 \strokec6 *\cf4 \strokec4  \cf7 \strokec7 60\cf4 \strokec4  \cf6 \strokec6 *\cf4 \strokec4  \cf7 \strokec7 60\cf6 \strokec6 ;\cf4 \strokec4 \
        timestamp \cf6 \strokec6 =\cf4 \strokec4  _daysFromDate\cf6 \strokec6 (\cf4 \strokec4 year\cf6 \strokec6 ,\cf4 \strokec4  month\cf6 \strokec6 ,\cf4 \strokec4  day\cf6 \strokec6 )\cf4 \strokec4  \cf6 \strokec6 *\cf4 \strokec4  SECONDS_PER_DAY\cf6 \strokec6 ;\cf4 \strokec4 \
    \cf6 \strokec6 \}\cf4 \strokec4 \
\
    \cf5 \strokec5 function\cf4 \strokec4  diffDays\cf6 \strokec6 (\cf5 \strokec5 uint\cf4 \strokec4  fromTimestamp\cf6 \strokec6 ,\cf4 \strokec4  \cf5 \strokec5 uint\cf4 \strokec4  toTimestamp\cf6 \strokec6 )\cf4 \strokec4  \cf8 \strokec8 internal\cf4 \strokec4  \cf8 \strokec8 pure\cf4 \strokec4  \cf15 \strokec15 returns\cf4 \strokec4  \cf6 \strokec6 (\cf5 \strokec5 uint\cf4 \strokec4  _days\cf6 \strokec6 )\cf4 \strokec4  \cf6 \strokec6 \{\cf4 \strokec4 \
        \cf5 \strokec5 uint\cf4 \strokec4  SECONDS_PER_DAY \cf6 \strokec6 =\cf4 \strokec4  \cf7 \strokec7 24\cf4 \strokec4  \cf6 \strokec6 *\cf4 \strokec4  \cf7 \strokec7 60\cf4 \strokec4  \cf6 \strokec6 *\cf4 \strokec4  \cf7 \strokec7 60\cf6 \strokec6 ;\cf4 \strokec4 \
        \cf10 \strokec10 require\cf6 \strokec6 (\cf4 \strokec4 fromTimestamp \cf6 \strokec6 <=\cf4 \strokec4  toTimestamp\cf6 \strokec6 );\cf4 \strokec4 \
        _days \cf6 \strokec6 =\cf4 \strokec4  \cf6 \strokec6 (\cf4 \strokec4 toTimestamp \cf6 \strokec6 -\cf4 \strokec4  fromTimestamp\cf6 \strokec6 )\cf4 \strokec4  \cf6 \strokec6 /\cf4 \strokec4  SECONDS_PER_DAY\cf6 \strokec6 ;\cf4 \strokec4 \
    \cf6 \strokec6 \}\cf4 \strokec4 \
\
    \cf5 \strokec5 function\cf4 \strokec4  getYear\cf6 \strokec6 (\cf5 \strokec5 uint\cf4 \strokec4  timestamp\cf6 \strokec6 )\cf4 \strokec4  \cf8 \strokec8 internal\cf4 \strokec4  \cf8 \strokec8 pure\cf4 \strokec4  \cf15 \strokec15 returns\cf4 \strokec4  \cf6 \strokec6 (\cf5 \strokec5 uint\cf4 \strokec4  year\cf6 \strokec6 )\cf4 \strokec4  \cf6 \strokec6 \{\cf4 \strokec4 \
        \cf5 \strokec5 uint\cf4 \strokec4  SECONDS_PER_DAY \cf6 \strokec6 =\cf4 \strokec4  \cf7 \strokec7 24\cf4 \strokec4  \cf6 \strokec6 *\cf4 \strokec4  \cf7 \strokec7 60\cf4 \strokec4  \cf6 \strokec6 *\cf4 \strokec4  \cf7 \strokec7 60\cf6 \strokec6 ;\cf4 \strokec4 \
        \cf6 \strokec6 (\cf4 \strokec4 year\cf6 \strokec6 ,,)\cf4 \strokec4  \cf6 \strokec6 =\cf4 \strokec4  _daysToDate\cf6 \strokec6 (\cf4 \strokec4 timestamp \cf6 \strokec6 /\cf4 \strokec4  SECONDS_PER_DAY\cf6 \strokec6 );\cf4 \strokec4 \
    \cf6 \strokec6 \}\cf4 \strokec4 \
\cf6 \strokec6 \}\cf4 \strokec4 \
\
\
}