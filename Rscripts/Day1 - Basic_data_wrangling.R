library (readxl) ## One way to read excel files to R
library (compareGroups) #For nicely formatted descriptive tables
library (mosaic) # For creating factors
library (stargazer) #Nicely formatted regression models.
library (caret) 
library (randomForest)
library (tidyr)
library (glmnet) # for logit models in caret
# If you are unable to load any of the package, remember to install.packages(pkg) and then rerun library(pkg)


#' Remember to copy path and include the path to your dataset below.
#' Download data from: https://www.worldvaluessurvey.org/WVSDocumentationWV7.jsp
wvs <- read_xlsx("D:\\OneDrive\\Rstats\\SICSS-CU2022\\Rscripts\\Data\\WVS.xlsx")
glimpse(wvs)
table(wvs$`Q2: Important in life: Friends`)

wvs_updt <- wvs %>%
            rename (urban = `H_URBRURAL: Urban-Rural`,
                    religion = `Q289: Religious denominations - major groups`,
                    sex = `Q260: Sex`,
                    education = `Q275: Highest educational level: Respondent [ISCED 2011]`,
                    settlement = `H_SETTLEMENT: Settlement type`,
                    ethnic = `Q290: Ethnic group`,
                    age = `Q262: Age`,
                    hell = `Q167: Believe in: hell`,
                    trust_family = `Q58: Trust: Your family`,
                    income = `Q288R: Income level (Recoded)`,
                    SHealth = `Q47: State of health (subjective)`,
                    no_medicine = `Q53: Frequency you/family (last 12 month): Gone without needed medicine or treatment that you needed`) %>% 
            mutate (StHealth = ifelse((SHealth < 3),
                                      "Good", "NotGood") %>% as.factor(),
                    sex = ifelse((sex == 1), "Male", "Female") %>% as.factor(),
                    urban = ifelse((urban == 1), "Urban", "Rural"),
                    hell = ifelse((hell == 1), "Yes", "No") %>% as.factor(),
                    settlement = derivedFactor("Capital" = (settlement == 1 | settlement == 2),
                                               "District" = (settlement == 3),
                                               "Another city" = (settlement == 4),
                                               "Village" = (settlement == 5),
                                               .default = NA),
                    education = derivedFactor("No Education" = (education == 0),
                                              "Primary" = (education == 1),
                                              "Secondary" = (education == 2 | education == 3 | education == 4 | education == 5),
                                              "Tertiary" = (education == 6 | education == 7 | education == 8),
                                              .default = NA),
                    religion = derivedFactor("No religion" = (religion == 0),
                                             "Christian" = (religion ==1 | religion == 2 | religion == 3),
                                             "Muslim" = (religion == 5),
                                             "Others" = (religion == 4| religion == 6 | religion == 7 | religion == 8),
                                             .default = NA),
                    age_grp = derivedFactor("18-34" = (age >= 18 & age <= 34),
                                             "35-54" = (age >= 35 & age <= 54),
                                             "55+" = (age >= 55),
                                             .default = NA),
                    income = derivedFactor("Low" = (income == 1),
                                           "Medium" = (income == 2),
                                           "High" = (income == 3),
                                           .default = NA),
                    trust_family = derivedFactor("Trust Completely" = (trust_family == 1),
                                           "Trust Somewhat" = (trust_family == 2),
                                           "No Trust" = (trust_family == 3 | trust_family == 4),
                                           .default = NA),
                    
                    no_medicine = derivedFactor("Often" = (no_medicine == 1),
                                                 "Sometimes" = (no_medicine == 2),
                                                 "Rarely" = (no_medicine == 3),
                                                "Never" = (no_medicine == 4),
                                                 .default = NA)) %>% 
              select(age, sex, education, 
                     religion, urban, 
                     settlement, no_medicine, 
                     trust_family, income,
                     hell, StHealth)


glimpse(wvs_updt)

## Univariate Descriptive Stats
descrTable(wvs_updt)

## Bivariate Table
cross_tab <- compareGroups(StHealth ~ .,
                           data = wvs_updt, byrow = TRUE)
createTable(cross_tab)


#' Logistic regression model (because our outcome is a dummy)
#' I have also specified outcome ~ . to regress all variables in the
#' dataset over the outcome. If you need to regress only a few variables,
#' try outcome ~ var1 + var2 + var3 + var4

logit <- glm(StHealth ~ .,
             data = train_data,
             family = binomial(link = "logit"))
summary(logit)



stargazer(logit, ci = TRUE,
          type = "text", 
          single.row = TRUE,
          apply.coef = exp)


### What else can you do? Surprise us!