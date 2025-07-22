**Goal**

The aim of this project is to clean the global passengers cars sales as reported by the  International Organization of Motor Vehicle Manufacturers (OICA). The input is a raw sales data from the 2019 to 2019 and the output is a tidy sales dataset. The data can be found on the official [OICA website.](https://www.oica.net/category/sales-statistics/)
<img width="1366" height="1092" alt="image" src="https://github.com/user-attachments/assets/7aee11d5-912e-4f8a-81f4-9c1f8edee2e0" />


**Skills**

The most important skill I practiced in this project is critical thinking and researching. For instance, I identified more than two methods to rename the column names. I would have used the `stringr` package with other base r functions to separate the characters, put them in another column and then deselect them. However, I decided to go with the `rename()` function since it was the most straight forward desite the extensive manual work. Other skills I developed during the project include data transformation using `select()`, `pivot_longer()` etc.

**Tools**

Tidyverse, readxl, and janitor (R-programming)

**Results**

The ouput datasets did not have duplicates or missing values. All variables had appropriate class (or type) with each value stored in its own cell. The column names and observations in the country column were more readable. 

**Lesson**

I have mastered transforming untidy numeric data. There was limited untidy strings characters so I still need more practice with the `stringr` package. Having learned how to create multiple dataframes from a single one, I also need to practice with joining different datasets to a single one.
