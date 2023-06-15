#' Apply Cleaning Modules
#'
#' A wrapper function for applying all of the cleaning functions and selecting the
#' desired variables/observations for the analysis by applying the select_data function.
#'
#' @param data_list List. List of data tables returned from the FRS cleaning functions.
#' @param ages Integer vector - the ages in single years to retain. If NULL (default), retain all ages.
#' @param keep_vars Character vector - the names of the variables to keep (defaults to NULL - retaining all variables).
#' @param complete_vars Character vector - the names of the variables on which the selection of complete cases will be based.
#' If NULL (default) no complete-case filtering is applied.
#' @return Returns a new set of variables
#' @export
frs_clean_global <- function(data_list,
                             ages = NULL,
                             keep_vars = NULL,
                             complete_vars = NULL
) {

  #################################################
  ## RUN THE CLEANING MODULES AND COMBINE DATA ####

  ### demographics and identifiers

  cat(crayon::yellow("\n\tCleaning Demographic Variables\n"))

  demographics <- frsclean::clean_demographic(data = data_list$data,
                                              main_data = data_list$main_data)

  ### income / tax data cleaning

  cat(crayon::yellow("\n\tCleaning Income and Tax Variables\n"))

  income_data  <- frsclean::clean_income(data = data_list$data,
                                         pension_data = data_list$pension_data,
                                         job_data = data_list$job_data,
                                         oddjob_data = data_list$oddjob_data,
                                         accounts_data = data_list$accounts_data,
                                         benefits_data = data_list$benefits_data)

  ### expenditure data cleaning

  cat(crayon::yellow("\n\tCleaning Expenditure Variables\n"))

  exp_data <- frsclean::clean_expenditure(data = data_list$data,
                                          maint_data = data_list$maint_data,
                                          penprov_data = data_list$penprov_data)

  ### labour market

  cat(crayon::yellow("\n\tCleaning Labour Market Variables\n"))

  labour_market <- frsclean::clean_labmarket(data = data_list$data,
                                             job_data = data_list$job_data,
                                             income_data = income_data)

  #########################
  ### Retain variables

  final_data <- merge(demographics, income_data, by = c("sernum","benunit","person"))
  final_data <- merge(final_data,   labour_market, by = c("sernum","benunit","person"))
  final_data <- merge(final_data,   exp_data, by = c("sernum","benunit","person"))

  final_data[, c("sernum","benunit","person") := NULL]

  cat(crayon::yellow("\tdone\n"))

  ##################################################
  ## COMBINE DATASETS ##############################

  final_data <- frsclean::select_data(data = final_data,
                                      ages = ages,
                                      keep_vars = keep_vars,
                                      complete_vars = complete_vars)


  return(final_data)
}