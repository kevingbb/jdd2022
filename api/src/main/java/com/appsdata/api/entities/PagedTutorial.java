package com.appsdata.api.entities;

import java.util.List;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;
import lombok.EqualsAndHashCode;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@ToString
@EqualsAndHashCode
public class PagedTutorial {

    //Model Specific Properties
    private Integer totalItems;
    private List<Tutorial> tutorials;
    private Integer totalPages;
    private Integer currentPage;

}
