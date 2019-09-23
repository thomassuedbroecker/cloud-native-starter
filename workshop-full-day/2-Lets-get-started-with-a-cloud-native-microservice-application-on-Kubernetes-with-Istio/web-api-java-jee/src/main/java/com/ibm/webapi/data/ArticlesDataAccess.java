package com.ibm.webapi.data;

import java.util.List;
import com.ibm.webapi.business.CoreArticle;
import com.ibm.webapi.business.InvalidArticle;

public interface ArticlesDataAccess {
	public CoreArticle addArticle(CoreArticle article) throws NoConnectivity, InvalidArticle;
  
    public List<CoreArticle> getArticles(int amount) throws NoConnectivity;
}