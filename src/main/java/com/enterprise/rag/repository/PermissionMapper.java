package com.enterprise.rag.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.enterprise.rag.domain.Permission;
import org.apache.ibatis.annotations.Mapper;

/**
 * 权限Mapper
 */
@Mapper
public interface PermissionMapper extends BaseMapper<Permission> {
}
