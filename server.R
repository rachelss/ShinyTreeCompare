library(shiny)
library(magrittr)
library(ape)
library(ggtree)
library(gridExtra)
library(cowplot)
library(shinyBS)
library(shinyLP)
library(shinythemes)

shinyServer(function(input, output, session) {
  
  #read tree either default or uploaded
  mammals <- reactive({
    
    if (is.null(input$file)){
      #Schwartz et al BMC Bioinf 2015 results
      
      #replace species names before returning
      return(read.tree("mammal_raxml_bmc_paper_data/alltrees.tre"))
    }
    else{
      return(read.tree(input$file$datapath))
    }
    
  })
  
  #get species list
  species <- reactive({
    sort(as.character(mammals()[[1]]["tip.label"][[1]]))
  })
  
  output$select = renderUI({ #creates select box object called in ui
    spp <- species()
    selectInput(inputId = "select", #name of input
                label = "Select two species:", #label displayed in ui
                choices = spp, multiple = TRUE,
                # calls unique values from the State column in the previously created table
                selected = c(spp[1],spp[2]) #default choice (not required)
    )
  })
  
  output$outgroup = renderUI({
    selectInput(inputId = "outgroup", #name of input
                label = "Select outgroup:", #label displayed in ui
                choices = species()
                # calls unique values from the State column in the previously created table
                #selected = c(species[length(species)]) #default choice (not required)
    )
    
  })
  #set root for each tree
  mammals2 <- reactive({
    trees <- mammals() #get trees
    numtrees <- length(trees) #number of trees
    m <- vector("list", numtrees) #empty vector to hold rooted trees
    
    for (i in 1:numtrees){
      m[i]<-root(trees[i], outgroup = input$outgroup, resolve.root = TRUE)
    }
    m
  })
  
  #Prompt to select species to get mrca/clade for
  families <- reactive({
    validate(
      need(length(input$select) == 2, 
           "Please select two families to highlight the clade containing their MRCA")
    )
    input$select
  })
  
  p <- reactive({
    trees <- mammals2()
    myplots <- vector("list", length(trees))
    
    for (i in 1:length(trees)){
      mrca <- getMRCA(trees[[i]], tip=families())
      cladetree <- groupClade(trees[[i]], .node=mrca)
      if(input$brlens == 1){
        myplots[[i]] <- ggtree(cladetree, aes(color=group, linetype=group))+ 
          geom_tiplab() #+ 
        #scale_color_manual(values=c("black", "red")) 
      }
      else{
        myplots[[i]] <- ggtree(cladetree, aes(color=group, linetype=group), branch.length="none")+ 
          geom_tiplab() #+ 
        #scale_color_manual(values=c("black", "red"))
      }
    }
    myplots
  })
  
  output$phyloPlot <- renderPlot({
    plot_grid(plotlist = p(), ncol=2)
  },
  height = function() {
    2*session$clientData$output_phyloPlot_width
  }
  )
  
}
)